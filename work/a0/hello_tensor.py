import torch
from torch.utils.data import DataLoader
import matplotlib.pyplot as plt

print("torch版本：",torch.__version__)
if torch.cuda.is_available()==True:
    print("CUDA可用:True")
    x=torch.arange(12, dtype=torch.float32)
    x.reshape((3,4))
    print("x=",x)
    print("形状:",x.shape)
    print("元素个数：",x.numel())
    g=x.to("cuda")
    g.cpu()
    print("搬到显卡上：",g.device)
    x=x*2
    print("乘2再搬回来：",x)
else:
    print("CUDA不可用:False")


