# This file is to solve the problem of loading densenet
# Missing key(s) in state_dict: "features.denseblock1.denselayer1.norm1.weight",...
# Unexpected key(s) in state_dict: "features.denseblock1.denselayer1.norm.1.weight",...
import os.path

import torch
import collections

weight_path = 'D:\\CodeField\\DualSparse\\tmp\\'
save_path = 'D:\\CodeField\\DualSparse\\weight\\'
item = ['densenet121.pth', 'densenet161.pth', 'densenet169.pth', 'densenet201.pth']

for i in item:
    state_dict = torch.load(os.path.join(weight_path, i))

    # 为了解决键不匹配的问题，我们可以定义一个新的状态字典，它将包含修改后的键
    new_state_dict = collections.OrderedDict()

    # 遍历原始状态字典中的所有键和值
    for k, v in state_dict.items():
        # 这里我们决定如何修改键。例如，我们可能需要移除前缀或者替换某些字符
        # 'features.' 替换为空，'norm.1' 替换为 'norm1.'，'conv.1' 替换为 'conv1.' 等
        # 注意：修改后的键必须与模型定义中的键相匹配
        k = k.replace('norm.1', 'norm1')  # 替换 'norm.1' 为 'norm1'
        k = k.replace('conv.1', 'conv1')  # 替换 'conv.1' 为 'conv1'
        k = k.replace('norm.2', 'norm2')  # 替换 'norm.2' 为 'norm2'
        k = k.replace('conv.2', 'conv2')  # 替换 'conv.2' 为 'conv2'
        # 添加修改后的键值对到新的状态字典中
        new_state_dict[k] = v

    torch.save(new_state_dict, os.path.join(save_path, i))
