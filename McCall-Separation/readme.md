# McCall Model with Separation

Consider a model of unemployment search where:

- An unemployed worker receives a job offer with a wage <img src="https://render.githubusercontent.com/render/math?math=w"> from a distribution with some density $f(w)$. Upon receiving the offer, the agent must decide between accepting and rejecting it. If the offer is accepted, the agent gets $w$ in the current period and enters the next period employed with wage $w$. If the offer is rejected, the agent collects $b$ (home production or unemployment benefits) and waits until next period, when another offer arrives.
- An employed worker enters the period with wage $w$ and next period he retains the job with probability $(1-\lambda)$ and loses the job with probability $\lambda$.

Importantly: an agent that becomes unemployed gets a new offer instantaneously. That is, an agent that becomes unemployed does not necessarily have to stay unemployed and derive $b$ for one period.

The value functions therefore satisfy:
$$\begin{align}
    &U(w) = \max \{U, V(w)\}\\
    &U = b + \beta \int_{\underline{w}}^{\overline{w}} U(w')dw\\
    &V(w) = w + \beta(1-\lambda)V(w) + \beta\lambda\int_{\underline{w}}^{\overline{w}}U(w')dw
\end{align}$$
Which may be interpreted as follows:
- $U(w)$ is the value of holding an offer of wage $w$ this period.
- $U$ is the value of having chosen to be unemployed this period (this is naturally constant).
- $V(w)$ is the value being employed at wage $w$ this period.

In my solution, and for computational ease, I assume that the wage distribution follows:
$$w\sim U(10,20)$$

Nonetheless, this can be easily modified if needed.

Further, I assume that utility is linear and pick the following parameters:
$$\underline{w} = 10,\ \overline{w} = 20,\ \beta=0.98,\ \lambda=0.5,\ b=8.0$$

This results in the following:

![image](solution.png)

Notice that the reservation wage is around $14.2$, that $V(w)$ is linearly increasing in $w$ and that $U$ is constant.
