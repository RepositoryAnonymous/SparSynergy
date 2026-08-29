# This file is to prune the models
# It was written with reference to NVIDIA apex.asp
# Author: Yang Jingkui
# Date: 2024-4-28
from load_model_data import load_model, load_dataset
import torch
import torchvision
import sparse_masklib
from validate import validate, single_val


def single_prune(arch, weight_path, dataset_path, n=2, m=4):
    # ==> initial
    # whitelist: Module types approved for sparsity.
    whitelist = [torch.nn.Linear, torch.nn.MultiheadAttention]  # torch.nn.Conv1d, torch.nn.Conv2d, torch.nn.Conv3d

    # load model
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    file_name = arch+'.pth'
    model = load_model(arch, weight_path+'original\\'+file_name, device)

    # create sparse parameter list
    # Torchvision remove APIs that were deprecated before 0.8 (#5386) in 0.12.0, torchvision.ops.misc.Conv2d is removed
    sparse_parameter_list = {torch.nn.Linear: ['weight'], torch.nn.Conv1d: ['weight'],
                             torch.nn.Conv2d: ['weight'], torch.nn.Conv3d: ['weight'],
                             torch.nn.modules.linear.NonDynamicallyQuantizableLinear: ['weight'],
                             torch.nn.MultiheadAttention: ['q_proj_weight', 'k_proj_weight', 'v_proj_weight',
                                                           'in_proj_weight']}

    # create eligible_modules list
    eligible_modules_list = []
    for name, mod in model.named_modules():
        if isinstance(mod, tuple(whitelist)):
            eligible_modules_list.append((name, mod))

    # iterate eligible modules and decorate
    sparse_parameters = []
    for name, module in eligible_modules_list:
        sparse_parameters_item = sparse_parameter_list[type(module)]
        for p_name, p in module.named_parameters():
            if p_name in sparse_parameters_item and p.requires_grad:
                mask = torch.ones_like(p).bool()
                buffname = p_name.split(".")[-1]  # buffer names cannot contain "."
                module.register_buffer('__%s_mma_mask' % buffname, mask)
                sparse_parameters.append((name, module, p_name, p, mask))

    # ==> pruning
    with torch.no_grad():
        for i, (module_name, module, p_name, p, mask) in enumerate(sparse_parameters):
            # if i < 3:  # ignore the first layer
            #     continue
            mask.set_(sparse_masklib.create_mask(p).bool())
            p.mul_(mask)
            # in-place multiplication, so pruned weights are 0-values, hence checkpoint will have 0s for pruned weights

    # ==> validate the model
    val_loader = load_dataset(dataset_path)
    validate(model, val_loader, device)
    # ==> save model
    torch.save(model.state_dict(), weight_path+'prune\\'+file_name)


if __name__ == '__main__':
    weight_path = 'D:\\CodeField\\DualSparse\\weight\\'
    dataset_path = 'D:\\CodeField\\DualSparse\\dataset\\'
    arch = 'resnet50'

    # single_val(arch, weight_path+'original\\', dataset_path)

    single_prune(arch, weight_path, dataset_path, n=2, m=4)
