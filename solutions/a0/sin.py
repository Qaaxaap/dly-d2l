"""A0 任务二参考答案。**做完再看。**

运行：
    just run solutions/a0/sin.py

图片存在脚本旁边：写 `work/a0/sin.py` 时，存出来就是 `work/a0/sin.png`。
（写死成 "work/a0/sin.png" 也行，用 `Path(__file__)` 的好处是不管从哪个目录跑都对。）
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")  # 必须在 import pyplot 之前

import matplotlib.pyplot as plt
import torch

x = torch.linspace(0, 2 * 3.141592653589793, 200)

plt.figure(figsize=(5, 3))
plt.plot(x.numpy(), torch.sin(x).numpy())  # matplotlib 只认 numpy，先转
plt.xlabel("x")
plt.ylabel("sin(x)")

out = Path(__file__).with_name("sin.png")
plt.savefig(out, dpi=120)
print(f"已保存 {out.relative_to(Path.cwd())}")
