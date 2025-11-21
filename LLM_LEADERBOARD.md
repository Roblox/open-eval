## LLM Leaderboard on Roblox Studio Assistant

<table>
<thead>
    <tr>
        <th rowspan="2">Model</th>
        <th colspan="4" class="eval-pass">Pass Rate </th>
        <th colspan="2" class="response-behavior">Tool Calling</th>
    </tr>
    <tr>
        <th class="eval-pass"><strong>Pass@1</strong></th>
        <th class="eval-pass"><strong>Pass@5</strong></th>
        <th class="eval-pass"><strong>Cons@5</strong></th>
        <th class="eval-pass"><strong>All@5</strong></th>
        <th class="response-behavior"><strong>Avg Tool Error Rate </strong></th>
    </tr>
</thead>
<tbody>
    <tr>
        <td class="model-name">Gemini 3 Pro</td>
        <td><strong>61.28%</strong></td>
        <td><strong>77.02%</strong></td>
        <td><strong>62.54%</strong></td>
        <td><strong>44.32%</strong></td>
        <td>3.80%</td>
    </tr>
    <tr>
        <td class="model-name">Gemini 2.5 Pro</td>
        <td>46.82%</td>
        <td>66.53%</td>
        <td>48.48%</td>
        <td>25.88%</td>
        <td>8.96%</td>
    </tr>
    <tr>
        <td class="model-name">Gemini 2.5 Flash</td>
        <td>31.28%</td>
        <td>51.71%</td>
        <td>29.65%</td>
        <td>16.95%</td>
        <td>8.95%</td>
    </tr>
    <tr>
        <td class="model-name">Claude Sonnet 4.5</td>
        <td>54.53%</td>
        <td>69.02%</td>
        <td>56.40%</td>
        <td>37.60%</td>
        <td><strong>3.27%<strong></td>
    </tr>
    <tr>
        <td class="model-name">Claude Haiku 4.5</td>
        <td>45.00%</td>
        <td>61.81%</td>
        <td>46.61%</td>
        <td>26.24%</td>
        <td>6.80%</td>
    </tr>
    <tr>
        <td class="model-name">GPT 5.1</td> 
        <td>40.54%</td>
        <td>62.05%</td>
        <td>40.43%</td>
        <td>21.74%</td>
        <td>4.70%</td>
    </tr>
    <tr>
        <td class="model-name">GLM 4.5</td>
        <td>51.49%</td>
        <td>68.24%</td>
        <td>52.21%</td>
        <td>37.00%</td>
        <td>4.93%</td>
    </tr>
    <tr>
        <td class="model-name">GLM 4.6</td>
        <td>50.61%</td>
        <td>67.40%</td>
        <td>52.00%</td>
        <td>32.54%</td>
        <td>9.50%</td>
    </tr>
    <tr>
        <td class="model-name">LIMI GLM 4.5</td>
        <td>47.70%</td>
        <td>64.37%</td>
        <td>48.53%</td>
        <td>31.04%</td>
        <td>11.30%</td>
    </tr>
    <tr>
        <td class="model-name">Kimi K2 Thinking</td>
        <td>44.26%</td>
        <td>64.38%</td>
        <td>45.88%</td>
        <td>22.90%</td>
        <td>4.30%</td>
    </tr>
    <tr>
        <td class="model-name">Minimax M2</td>
        <td>42.43%</td>
        <td>62.84%</td>
        <td>43.22%</td>
        <td>24.51%</td>
        <td>7.90%</td>
    </tr>
    <tr>
        <td class="model-name">GPT-OSS-120B</td>
        <td>42.16%</td>
        <td>61.16%</td>
        <td>41.82%</td>
        <td>26.63%</td>
        <td>6.41%</td>
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
