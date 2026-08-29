# This file is aimed to validate the processed models, like quantization and pruning
# use Single and batch valid to test
# Author: Yang Jingkui
# Date: 2024-4-28

import os
import csv
import time
import torch
from torch.utils.data import DataLoader
from torchvision import datasets, transforms, models
from load_model_data import load_dataset, load_model


class AverageMeter(object):
    """Computes and stores the average and current value"""
    def __init__(self):
        self.val = 0
        self.avg = 0
        self.sum = 0
        self.count = 0

    def reset(self):
        self.val = 0
        self.avg = 0
        self.sum = 0
        self.count = 0

    def update(self, val, n=1):
        self.val = val
        self.sum += val * n
        self.count += n
        self.avg = self.sum / self.count


def accuracy(output, target, topk=(1,)):
    # Computes the precision@k for the specified values of k
    maxk = max(topk)
    batch_size = target.size(0)

    _, pred = output.topk(maxk, 1, True, True)
    pred = pred.t()
    correct = pred.eq(target.view(1, -1).expand_as(pred))

    res = []
    for k in topk:
        correct_k = correct[:k].reshape(-1).float().sum(0)
        res.append(correct_k.mul_(100.0 / batch_size))
    return res


def validate(model, val_loader, device):
    # validation
    top1 = AverageMeter()
    top5 = AverageMeter()

    with torch.no_grad():
        model.eval()
        for i, (inputs, target) in enumerate(val_loader):
            # move inputs to device
            target = target.to(device)
            inputs = inputs.to(device)
            # get output
            outputs = model(inputs)
            # measure accuracy
            prec_top1, prec_top5 = accuracy(outputs.data, target.data, topk=(1, 5))
            top1.update(prec_top1.item(), inputs.size(0))
            top5.update(prec_top5.item(), inputs.size(0))

            if i % 100 == 0:
                print('Test: [{0}/{1}]\t'
                      'Acc@1 {top1.val:.3f} ({top1.avg:.3f})\t'
                      'Acc@5 {top5.val:.3f} ({top5.avg:.3f})'.format(i, len(val_loader), top1=top1, top5=top5))

    print(' * Acc@1 {top1.avg:.3f} Acc@5 {top5.avg:.3f}'.format(top1=top1, top5=top5))

    return top1.avg, top5.avg


def single_val(arch, weight_path, dataset_path):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    file_name = arch+'.pth'

    val_loader = load_dataset(dataset_path)
    model = load_model(arch, weight_path+file_name, device)

    top1, top5 = validate(model, val_loader, device)
    print('=>Single Test Finish')
    return top1, top5


def batch_val(weight_path, dataset_path, result_path):
    csv_name = time.strftime('%Y-%m-%d-%H-%M-%S', time.localtime()) + '.csv'
    csv_path = os.path.join(result_path, csv_name)

    csvfile = open(csv_path, 'w', newline='')
    writer = csv.writer(csvfile)
    writer.writerow(['model', 'top1', 'top5'])

    for dir_path, dir_names, file_names in os.walk(weight_path):
        for file_name in file_names:
            top1, top5 = single_val(file_name[:-4], os.path.join(dir_path, file_name), dataset_path)
            writer.writerow([file_name, top1, top5])
    csvfile.close()


if __name__ == '__main__':
    weight_path = 'D:\\CodeField\\DualSparse\\weight\\original\\'
    dataset_path = 'D:\\CodeField\\DualSparse\\dataset\\'
    result_path = 'D:\\CodeField\\DualSparse\\results\\'
    arch = 'resnet18'

    single_val(arch, weight_path, dataset_path)

    # batch_val(weight_path, dataset_path, result_path)
