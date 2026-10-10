"""A0 任务一参考答案。**做完再看。**

运行：
    just run solutions/a0/hello_tensor.py
"""

import torch

print("torch 版本：", torch.__version__)
print("CUDA 可用：", torch.cuda.is_available())

x = torch.arange(12, dtype=torch.float32).reshape(3, 4)

print("x =\n", x)
print("形状：", x.shape, "元素个数：", x.numel())

if torch.cuda.is_available():
    g = x.to("cuda")
    print("搬到显卡上：", g.device)
    print("乘 2 再搬回来：", (g * 2).cpu())
