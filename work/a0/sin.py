import torch
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use("Agg")

x=torch.linspace(0,2*3.14159,200)
y=torch.sin(x)

plt.figure(figsize=(5,3))
plt.plot(x,y)
plt.xlabel("x")
plt.ylabel("sin(x)")
plt.savefig("work/a0/sin.png",dpi=150)


