#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#     "aiohttp",
#     "python-dotenv",
# ]
# ///
from pathlib import Path
import argparse
import asyncio
import time
import aiohttp
import logging
import glob
import os
from dotenv import load_dotenv
import ssl
import warnings

logger = logging.getLogger(__name__)

BASE_URL = "https://apis.roblox.com/open-eval-api/v1"


async def eval(
    file: str,
    base_url: str,
    session: aiohttp.ClientSession,
    timeout: int,
    poll_interval: int,
    api_key: str,
    delay: int = 0,
    use_reference_mode: bool = False,
    custom_llm_info: dict = None,
    verbose_headers: bool = False
) -> str:
    await asyncio.sleep(delay)
    payload = {
        "name": f"eval-run-{file}-{int(time.time())}",
        "description": f"Evaluation run using {file}",
        "input_script": Path(file).read_text(),
    }
    if use_reference_mode:
        payload["use_reference_mode"] = "true"
    if custom_llm_info:
        payload["custom_llm_info"] = custom_llm_info
    custom_headers = {}
    if api_key:
        custom_headers["x-api-key"] = api_key
    submit_url = f"{base_url}/eval"

    job_id = None
    if verbose_headers:
        print(f"\n{'='*60}")
        print(f"[VERBOSE] POST {submit_url}")
        print(f"[VERBOSE] Request Headers:")
        for key, value in custom_headers.items():
            # Mask API key for security
            display_value = value[:8] + "..." if key.lower() == "x-api-key" and len(value) > 8 else value
            print(f"  {key}: {display_value}")
    async with session.post(submit_url, json=payload, headers=custom_headers) as response:
        if verbose_headers:
            print(f"[VERBOSE] Response Status: {response.status}")
            print(f"[VERBOSE] Response Headers:")
            for key, value in response.headers.items():
                print(f"  {key}: {value}")
            print(f"{'='*60}\n")
        if response.status == 200:
            result = await response.json()
            job_id = result.get("job_id")
            if not job_id:
                raise Exception(f"Failed to get job_id from response for {file}: {await response.text()}")
            eval_records_url = f"{base_url}/eval-records/{job_id}"
            print(f"{file:<50}: Submitted - {eval_records_url}")
            logger.info(f"Submitted {file}. Job ID: {job_id}. Polling for status...")
        else:
            raise Exception(f"Failed to submit {file}: {response.status} {await response.text()}, {submit_url}")

    poll_url = f"{base_url}/eval-records/{job_id}"
    poll_interval = poll_interval  # seconds
    last_print_time = 0
    print_interval = 30  # seconds

    while True:
        await asyncio.sleep(poll_interval)
        current_time = time.time()
        async with session.get(poll_url, headers=custom_headers) as response:
            if response.status == 200:
                job_status_response = await response.json()
                job_status = job_status_response["record"]["jobStatus"]

                if job_status == "COMPLETED":
                    eval_succeeded = job_status_response["record"]["evalSucceeded"]
                    logger.info(f"Job {job_id} for {file} Completed. Eval Succeeded: {eval_succeeded}")
                    ret = "Success" if eval_succeeded else "Failure"
                    return f"{ret}"
                elif job_status == "FAILED":
                    logger.info(f"Job {job_id} for {file} Failed")
                    return f"Error"
                elif job_status == "QUEUED":
                    if current_time - last_print_time >= print_interval:
                        print(f"{file:<50}: Queued, awaiting processing...")
                        last_print_time = current_time
                    logger.info(f"Job {job_id} for {file} is queued. Waiting for processing...")
                elif job_status == "PENDING":
                    if current_time - last_print_time >= print_interval:
                        print(f"{file:<50}: Eval running...")
                        last_print_time = current_time
                    logger.info(f"Job {job_id} for {file} is pending. Waiting for completion...")
                else:
                    raise Exception(f"Unexpected job status for {job_id}: {job_status}")
            else:
                raise Exception(f"Failed to poll status for {job_id}: {response.status} {await response.text()}")
            timeout -= poll_interval
            if timeout <= 0:
                return "Timeout"


def expand_file_patterns(patterns):
    files = []
    for pattern in patterns:
        if '*' in pattern or '?' in pattern:
            matched_files = glob.glob(pattern, recursive=True)
            if not matched_files:
                logger.warning(f"No files found matching pattern: {pattern}")
            files.extend(matched_files)
        else:
            if Path(pattern).exists():
                files.append(pattern)
            else:
                logger.warning(f"File not found: {pattern}")
    return sorted(files)

async def main():
    # Load environment variables from .env file
    load_dotenv()
    
    parser = argparse.ArgumentParser(description="Invoke eval API")
    parser.add_argument(
        "--api-key", type=str, default="", help="The API key for authentication"
    )
    parser.add_argument(
        "--use-reference-mode", action="store_true", help="Use reference mode for evaluation"
    )
    parser.add_argument(
        "--llm-name", type=str, help="Custom LLM name (e.g., 'gpt-4', 'claude-4')"
    )
    parser.add_argument(
        "--llm-url", type=str, default="dummy_url", help="Custom LLM endpoint URL"
    )
    parser.add_argument(
        "--llm-api-key", type=str, default=None, help="Custom LLM API key"
    )
    parser.add_argument(
        "--llm-model-version", type=str, help="Custom LLM model version"
    )
    parser.add_argument(
        "--max-concurrent", type=int, default=None, help="Maximum number of concurrent evaluations (default: unlimited)"
    )
    parser.add_argument(
        "--verbose-headers", action="store_true", help="Output HTTP request and response headers for debugging"
    )
    parser.add_argument("--files", type=str, nargs="+", help="List of lua files with evals (supports wildcards like *.lua or src/**/*.lua)")
    args = parser.parse_args()
    
    # Use environment variable as fallback if --api-key not provided
    api_key = args.api_key or os.getenv("OPEN_GAME_EVAL_API_KEY", "")
    
    if not api_key:
        raise ValueError("API key is required. Provide --api-key or set OPEN_GAME_EVAL_API_KEY in .env file")

    expanded_files = expand_file_patterns(args.files)
    if not expanded_files:
        logger.error("No files found matching the provided patterns")
        return

    logger.info(f"Found {len(expanded_files)} files to evaluate:")
    for file in expanded_files:
        logger.info(f"  - {file}")

    base_url = BASE_URL
    poll_interval = 10
    eval_timeout = 600

    # Construct custom LLM info if provided
    custom_llm_info = {}
    if not args.use_reference_mode:
        llm_api_key = args.llm_api_key or os.getenv("LLM_API_KEY", "")
        if not llm_api_key:
            raise ValueError("LLM API key is required when not using reference mode. Provide --llm-api-key or set LLM_API_KEY in .env file.\n This ensures you use your own LLM API key for evaluations.")
        custom_llm_info["api_key"] = llm_api_key
        
        if not args.llm_name:
            raise ValueError("LLM name is required when not using reference mode. Provide --llm-name (e.g., 'claude', 'gemini', 'openai').\n This ensures you use your own LLM API key for evaluations.")
        custom_llm_info["name"] = args.llm_name
        
        if not args.llm_model_version:
            warnings.warn("LLM model version is not provided when not using reference mode. Will be using the default model version for the provider.")
            if args.llm_name == "claude":
                custom_llm_info["model_version"] = "claude-sonnet-4-5-20250929"
            elif args.llm_name == "gemini":
                custom_llm_info["model_version"] = "gemini-2.5-pro"
            elif args.llm_name == "openai":
                custom_llm_info["model_version"] = "gpt-5"
            else:
                raise ValueError(f"Provider not supported: {args.llm_name}")
        else:
            custom_llm_info["model_version"] = args.llm_model_version

        if args.llm_url and args.llm_url != "dummy_url":
            custom_llm_info["url"] = args.llm_url
        else:
            custom_llm_info["url"] = "dummy_url"

    # Limit concurrent evaluations if specified
    max_concurrent = args.max_concurrent or len(expanded_files)

    ssl_ctx = ssl.create_default_context()
    connector = aiohttp.TCPConnector(ssl=ssl_ctx)

    async with aiohttp.ClientSession(connector=connector) as session:
        # Create semaphore to limit concurrent evaluations
        semaphore = asyncio.Semaphore(max_concurrent)

        async def eval_with_semaphore(file, index):
            async with semaphore:
                return await eval(file, base_url, session, delay=index * 0.5, timeout=eval_timeout,
                                api_key=api_key, use_reference_mode=args.use_reference_mode,
                                poll_interval=poll_interval, custom_llm_info=custom_llm_info,
                                verbose_headers=args.verbose_headers)

        tasks = [
            eval_with_semaphore(file, i)
            for i, file in enumerate(expanded_files)
        ]
        results_from_tasks = await asyncio.gather(*tasks, return_exceptions=True)

    for file, result in zip(expanded_files, results_from_tasks):
        print(f"{file:<50}: {result}")

    succeeded = sum(1 for r in results_from_tasks if isinstance(r, str) and r.startswith("Success"))
    print(f"Success rate: {100 * succeeded / len(expanded_files):.2f}% ({succeeded}/{len(expanded_files)})  ")

    errored = sum(1 for r in results_from_tasks if not isinstance(r, str) or r.startswith("Error"))
    if errored > 0:
        print(f"Server error rate: {100 * errored / len(expanded_files):.2f}% ({errored}/{len(expanded_files)})")


if __name__ == "__main__":
    asyncio.run(main())
