# This file is to load model and dataset
# Author: Yang Jingkui
# Date: 2024-4-28
import torch
from torch.utils.data import DataLoader
from torchvision import datasets, transforms, models


def load_model(arch, weight_path, device):
    print("=>Creating Model '{}'".format(arch))
    if arch == 'resnet18':
        model = models.resnet18(weights=None)
        checkpoint = torch.load(weight_path)
        model.load_state_dict(checkpoint)
        model.to(device)
    elif arch == 'resnet34':
        model = models.resnet34(weights=None)
        checkpoint = torch.load(weight_path)
        model.load_state_dict(checkpoint)
        model.to(device)
    elif arch == 'resnet50':
        model = models.resnet50(weights=None)
        checkpoint = torch.load(weight_path)
        model.load_state_dict(checkpoint)
        model.to(device)
    elif arch == 'resnet101':
        model = models.resnet101(weights=None)
        checkpoint = torch.load(weight_path)
        model.load_state_dict(checkpoint)
        model.to(device)
    elif arch == 'resnet152':
        model = models.resnet152(weights=None)
        checkpoint = torch.load(weight_path)
        model.load_state_dict(checkpoint)
        model.to(device)
    elif arch == 'densenet121':
        model = models.densenet121(weights=None)
        checkpoint = torch.load(weight_path)
        model.load_state_dict(checkpoint)
        model.to(device)
    elif arch == 'densenet161':
        model = models.densenet161(weights=None)
        checkpoint = torch.load(weight_path)
        model.load_state_dict(checkpoint)
        model.to(device)
    elif arch == 'densenet169':
        model = models.densenet169(weights=None)
        checkpoint = torch.load(weight_path)
        model.load_state_dict(checkpoint)
        model.to(device)
    elif arch == 'densenet201':
        model = models.densenet201(weights=None)
        checkpoint = torch.load(weight_path)
        model.load_state_dict(checkpoint)
        model.to(device)
    else:
        model = None
        raise Exception('Model Type not Supported')
    print('=>Loaded Pretrained Weight')
    return model


def load_dataset(dataset_path):
    transform = transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ])
    val_dataset = datasets.ImageNet(root=dataset_path, split='val', transform=transform)
    val_loader = DataLoader(val_dataset, shuffle=False, batch_size=32, num_workers=4, pin_memory=True)
    return val_loader
