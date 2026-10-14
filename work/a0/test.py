import torch

x = torch.arange(4, dtype=torch.float32)
x.to("cuda")
print(x.device)
