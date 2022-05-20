# McCall Model with Separation

Consider a model of unemployment search where:

- An unemployed worker receives a job offer with a wage <img src="https://render.githubusercontent.com/render/math?math=w"> from a distribution with some density <img src="https://render.githubusercontent.com/render/math?math=f(w)">. Upon receiving the offer, the agent must decide between accepting and rejecting it. If the offer is accepted, the agent gets <img src="https://render.githubusercontent.com/render/math?math=w"> in the current period and enters the next period employed with wage <img src="https://render.githubusercontent.com/render/math?math=w">. If the offer is rejected, the agent collects <img src="https://render.githubusercontent.com/render/math?math=b"> (home production or unemployment benefits) and waits until next period, when another offer arrives.
- An employed worker enters the period with wage <img src="https://render.githubusercontent.com/render/math?math=w"> and next period he retains the job with probability <img src="https://render.githubusercontent.com/render/math?math=(1-\lambda)"> and loses the job with probability <img src="https://render.githubusercontent.com/render/math?math=\lambda">.

Importantly: an agent that becomes unemployed gets a new offer instantaneously. That is, an agent that becomes unemployed does not necessarily have to stay unemployed and derive <img src="https://render.githubusercontent.com/render/math?math=b"> for one period.

The value functions therefore satisfy:
$$U(w) = \max \{U, V(w)\}$$
$$U = b + \beta \int_{\underline{w}}^{\overline{w}} U(w')dw$$
$$V(w) = w + \beta(1-\lambda)V(w) + \beta\lambda\int_{\underline{w}}^{\overline{w}}U(w')dw$$
Which may be interpreted as follows:
- <img src="https://render.githubusercontent.com/render/math?math=U(w)"> is the value of holding an offer of wage <img src="https://render.githubusercontent.com/render/math?math=w"> this period.
- <img src="https://render.githubusercontent.com/render/math?math=U"> is the value of having chosen to be unemployed this period (this is naturally constant).
- <img src="https://render.githubusercontent.com/render/math?math=V(w)"> is the value being employed at wage <img src="https://render.githubusercontent.com/render/math?math=w"> this period.

In my solution, and for computational ease, I assume that the wage distribution follows:
$$w\sim U(10,20)$$

Nonetheless, this can be easily modified if needed.

Further, I assume that utility is linear and pick the following parameters:
$$\underline{w} = 10,\ \overline{w} = 20,\ \beta=0.98,\ \lambda=0.5,\ b=8.0$$

This results in the following:

![image](solution.png)

Notice that the reservation wage is around <img src="https://render.githubusercontent.com/render/math?math=14.2">, that <img src="https://render.githubusercontent.com/render/math?math=V(w)"> is linearly increasing in <img src="https://render.githubusercontent.com/render/math?math=w"> and that <img src="https://render.githubusercontent.com/render/math?math=U"> is constant.