## LLM Leaderboard on Roblox Studio Assistant

<table>
<thead>
    <tr>
        <th rowspan="2">Model</th>
        <th colspan="4" class="eval-pass">Pass Rate </th>
        <th colspan="2" class="response-behavior">Tool Calling</th>
        <th colspan="1" class="cost">Cost $</th>
    </tr>
    <tr>
        <th class="eval-pass"><strong>Pass@1</strong></th>
        <th class="eval-pass"><strong>Pass@5</strong></th>
        <th class="eval-pass"><strong>Cons@5</strong></th>
        <th class="eval-pass"><strong>All@5</strong></th>
        <th class="response-behavior"><strong>Avg Tool Error Rate </strong></th>
        <th class="response-behavior"><strong>Explanation Rate with Tools</strong></th>
        <th class="response-behavior"><strong>Avg Cost $</strong></th>
    </tr>
</thead>
<tbody>
    <tr>
        <td class="model-name">Claude-4-sonnet-20250514</td>
        <td>55.59%</td>
        <td><strong>75.99%</strong></td>
        <td>56.68%</td>
        <td>34.80%</td>
        <td>40%</td>
        <td><strong>97%</strong></td>      
        <td>0.0507</td>
    </tr>
    <tr>
        <td class="model-name">Claude-sonnet-4-5-20250929</td>
        <td class="best-score"><strong>57.87%</strong></td>
        <td>74.43%</td>
        <td class="best-score"><strong>59.91%</strong></td>
        <td class="best-score"><strong>38.73%</strong></td>
        <td class="best-score">22%</td>
        <td class="best-score">90%</td>
        <td>0.0315</td>
    </tr>
    <tr>
        <td class="model-name">Qwen3-Coder 480B/A35B Instruct</td>
        <td>49.61%</td>
        <td class="best-score">76.26%</td>
        <td>50.56%</td>
        <td>23.84%</td>
        <td>67%</td>
        <td>47.30%</td>
        <td>n/a</td>
    </tr>
    <tr>
        <td class="model-name">GLM-4.6</td>
        <td>47.72%</td>
        <td>71.15%</td>
        <td>48.20%</td>
        <td>26.01%</td>
        <td class="best-score">15%</td>
        <td>-</td>
        <td>n/a</td>
    </tr>
    <tr>
        <td class="model-name">GLM-4.5</td>
        <td>49.76%</td>
        <td>70.10%</td>
        <td>50.87%</td>
        <td>29.22%</td>
        <td><strong>14%</strong></td>
        <td>-</td>
        <td>n/a</td>
    </tr>
    <tr>
        <td class="model-name">Gemini-2.5-pro<br>AUTO thinking, NO web</td>
        <td>48.58%</td>
        <td>67.00%</td>
        <td>49.16%</td>
        <td>30.59%</td>
        <td>40%</td>
        <td>92%</td>
        <td>0.0444</td>
    </tr>
    <tr>
        <td class="model-name">Gemini-2.5-flash-preview-09-2025<br>AUTO thinking, NO web</td>
        <td>37.24%</td>
        <td>63.04%</td>
        <td>35.61%</td>
        <td>17.72%</td>
        <td>69%</td>
        <td>49.50%</td>
        <td>0.0100</td>
    </tr>
</tbody>
</table>
</body>
</html>

**We are serving the open-source models using vLLM on a dedicated 8-way NVIDIA H200 cluster. <br>
**To ensure responsible and effective use, we advise that you prompt-tune the models and run them behind a robust safety guardrail.
<br>
💡 We see that agentic tasks in practice generate deep, multi-step execution paths, and enhancing the model's performance and subsequent evaluation metrics for these trajectories will be a key area of focus.

## Metrics Explaination
- Pass@1 -- average probability of success in 1 attempt
- Pass@5 -- average probability of success in at least 1 out of 5 attempts
- Cons@5 -- average probability of success in at least 3 out of 5 attempts
- All@5 -- average probability of success in 5 out of 5 attempts
- Avg Tool Error Rate -- average tool call error rates
- Explanation Rate with Tools -- quality of explanations when using tools
