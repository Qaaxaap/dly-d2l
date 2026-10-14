import torch

x=torch.arange(6,dtype=torch.float32)
x=x.reshape(2,3)
print(x.shape)
print(x.numel())
g=x.to("cuda")
g.cpu()
print(g.device)
print((g/2).cpu())
print(x)


