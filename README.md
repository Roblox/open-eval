# OpenEval

OpenEval is an evaluation framework for testing LLMs on Roblox game development tasks. This repository contains open-sourced evaluation scripts and tools for running automated assessments in the Roblox Studio environment.

## Prerequisites

### 1. Roblox Account
You'll need a Roblox account. If you don't have one, create a free account at [roblox.com](https://www.roblox.com).

### 2. OpenCloud API Key
To interact with the OpenEval API, you need to create an OpenCloud API key:

1. Navigate to [Creator Hub](https://create.roblox.com) and log in. Make sure you are viewing as user, not group.
2. Go to **All tools** (or **OpenCloud**) > **API Keys**
3. Create a new key with:
   - **Access Permissions**: `studio-evaluations`
   - **Operations**: `create`
   - Set an expiration date (recommended: 90 days)
4. Save and copy the generated key, which will be used as <your_api_key> in following commands.

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/Roblox/open-eval.git
cd open-eval
```

### 2. Install uv (one-time setup)
The project uses `uv` for dependency management. Install dependencies:
```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or with Homebrew
brew install uv

# Or with pip
pip install uv
```

### 3. Run Your Evaluation
You may save the API key generated in a file named `.env`, and name it `OPEN_EVAL_API_KEY`. See `.env.example` for a sample.
Alternatively, you can pass in the API key directly.

```bash
# Using API key stored in .env
uv run invoke_eval.py --files "Evals/001_make_cars_faster.lua"

# Or, pass in Open Eval API key manually
uv run invoke_eval.py --files "Evals/001_make_cars_faster.lua" --api-key your_api_key
```

It should show the status being "submitted" with a url, through which you can check the status of the eval with the Roblox account that owns the API key logged in. 
```bash
Evals/001_make_cars_faster.lua                    : Submitted - https://apis.roblox.com/open-eval-api/v1/eval-records/c4106612-0968-4480-90ba-e707d3bbe491
```

It is common for an eval to take 3-4 minutes to run and gather results. The script polls result every 10 seconds and print a status update every 30 seconds.

Once completed, it will return whether the eval run is successful or not. The default timeout is 10 minutes.

```bash
Evals/001_make_cars_faster.lua                    : Success
Success rate: 100.00% (1/1)  
```

## Understanding Eval Result
After eval completed, a result object will be returned as a part of http response. It is accessible through `https://apis.roblox.com/open-eval-api/v1/eval-records/{jobId}`

The eval is considered as a pass only if all checks are passed.
```
"results": [
      {
        "mode": "[EDIT]",
        "result": {
          "passes": 1,
          "fails": 0,
          "checks": 1,
          "warning": "",
          "error": "",
          "interruptions": []
        }
      }
    ],
```
### Eval result fields
- `passes`: Number of checks passed.
- `fails`: Number of checks failed.
- `checks`: Total number of checks. Equals to passes + fails.
- `warnings`: Number of warnings received when running the eval.
- `error`: Number of errors received when running the eval.

## More Usage

### Running Multiple Evaluations

```bash
# Run all evaluations
uv run invoke_eval.py --files "Evals/*.lua"

# Run specific pattern
uv run invoke_eval.py --files "Evals/0*_*.lua"

# Run with concurrency limit
uv run invoke_eval.py --files "Evals/*.lua" --max-concurrent 5
```

### Using Custom LLM Models

```bash
# With Gemini
uv run invoke_eval.py --files "Evals/001_make_cars_faster.lua" \
  --llm-name "gemini" \
  --llm-model-version "gemini-2.5-flash-preview-09-2025" \
  --llm-api-key $GEMINI_API_KEY

# With Claude
uv run invoke_eval.py --files "Evals/001_make_cars_faster.lua" \
  --llm-name "claude" \
  --llm-model-version "claude-4-sonnet-20250514" \
  --llm-api-key $CLAUDE_API_KEY

# With OpenAI
uv run invoke_eval.py --files "Evals/001_make_cars_faster.lua" \
  --llm-name "openai" \
  --llm-model-version "gpt-4o-2024-08-06" \
  --llm-api-key $OPENAI_API_KEY
```

## Command Line Options

```bash
uv run invoke_eval.py [OPTIONS]

Options:
  --api-key TEXT             Open Cloud API key studio-evaluation
  --llm-name TEXT            Name of provider, e.g. claude | gemini | openai
  --llm-api-key TEXT         LLM API key
  --llm-model-version TEXT   LLM model version, e.g. claude-4-sonnet-20250514
  --llm-url TEXT             LLM endpoint URL. Not yet supported, please put a placeholder string here.
  --max-concurrent INTEGER   Maximum concurrent evaluations
  --files TEXT [TEXT ...]    Lua files to evaluate (supports wildcards)
  --use-reference-mode       Use reference mode for evaluation. This is used for eval development and contribution, not for LLM assessment.
```

## Troubleshooting

### Common Issues

1. **API Key Not Found**: Ensure your API key is set in the `.env` file or passed via `--api-key`. See `.env.example` as an example.
2. **Permission Denied**: Verify your API key has proper scope (`studio-evaluation:create`).
3. **Timeout Errors**: Evaluations have a 10-minute timeout.
4. **File Not Found**: Check file paths and ensure evaluation files exist.
5. **SSL certificate verify failed**: Find the `Install Certificates.command` in finder and execute it. ([See details and other solutions](https://stackoverflow.com/questions/52805115/certificate-verify-failed-unable-to-get-local-issuer-certificate))

## API Reference

### Base URL
```
https://apis.roblox.com/open-eval-api/v1
```

### Endpoints

#### Submit Evaluation
```bash
curl -X POST 'https://apis.roblox.com/open-eval-api/v1/eval' \
  --header 'Content-Type: application/json' \
  --header "x-api-key: $OPEN_EVAL_API_KEY" \
  --data "$(jq -n --rawfile script Evals/001_make_cars_faster.lua '{
    name: "make_cars_faster",
    description: "Evaluation on make cars faster",
    input_script: $script
  }')"
```

#### Check Status
```bash
curl 'https://apis.roblox.com/open-eval-api/v1/eval-records/{job_id}' \
  --header "x-api-key: $OPEN_EVAL_API_KEY"
```

### Job Status Values
- `QUEUED`: Job is waiting to be processed
- `PENDING`: Job is being processed  
- `COMPLETED`: Job finished successfully
- `FAILED`: Job failed

### Custom LLM Configuration

#### With provider and model version
```bash
curl -X POST 'https://apis.roblox.com/open-eval-api/v1/eval' \
  --header 'Content-Type: application/json' \
  --header "x-api-key: $OPEN_EVAL_API_KEY" \
  --data "$(jq -n --rawfile script src/Evals/e_44_create_part.lua '{
    name: "create_part",
    description: "Evaluation on create part",
    input_script: $script,
    custom_llm_info: {
      name: "provider-name", // ← Provider only, claude | gemini | openai
      api_key: "your-provider-api-key",
      model_version: "model-version", // ← see example model versions below
      url: "dummy_url_not_effective",
    }
  }')"
```
Example model-versions
- For Gemini models (provider-name: “gemini”)
    - gemini-2.5-pro
    - gemini-2.5-flash-preview-09-2025
- For Claude models (provider-name: “claude”)
    - claude-4-sonnet-20250514
    - claude-sonnet-4-5-20250929
- For OpenAI models (provider-name: “openai”)
    - gpt-4o-2024-08-06


## Evaluation Structure

Each evaluation file follows this structure:

```lua
local eval: BaseEval = {
    scenario_name = "001_make_cars_faster", -- Name of the eval
    prompt = {
        {
            {
                role = "user",
                content = "Make the cars of this game 2x faster", -- User prompt
            }
        }
    },
    place = "racing.rbxl", --Name of placefile used. Currently only supports Roblox templates.
}

-- Setup necessary changes to the placefile before evaluation
eval.setup = function()
    -- Create necessary set up to placefile, including selection
end

-- Reference function (optional, used when running evals with use-reference-mode)
eval.reference = function()
    -- Expected behavior implementation. They are intentionally left blank in this set for the purpose of evaluation.
end

-- Validation function
eval.check_scene = function()
    -- Checks for edit mode
end

eval.check_game = function()
    -- Checks for play mode
end

return eval
```

## Contributing

This repository contains open-source evaluation scripts. To contribute:

1. Fork the repository
2. Create evaluation scripts following the established format
3. Test your evaluations thoroughly
4. Submit a pull request with clear documentation

## License

This project is part of Roblox's open-source initiative. Please refer to the repository's license file for details.

## Support
- Contact the Roblox team for API access and permissions

## LLM Leaderboard
[LLM_LEADERBOARD.md](./LLM_LEADERBOARD.md)
