from itertools import permutations

import torch

valid_m4n2_1d_patterns = None


def fill(x):  # compute density (helper fn to compute % NNZs in a tensor)
    return float(x.nonzero().size(0))/torch.numel(x)


def reshape_1d(matrix, m):  # reshape matrix into m-dimensional vectors: (h,w) -> (hw/m, m)
    # If not a nice multiple of m, fill with zeroes.
    shape = matrix.shape
    if matrix.shape[1] % m > 0:
        mat = torch.zeros((matrix.shape[0], matrix.shape[1] + (m-matrix.shape[1] % m)), dtype=torch.float, device='cuda')
        mat[:, :matrix.shape[1]] = matrix
        shape = mat.shape
        return mat.view(-1, m), shape
    else:
        return matrix.view(-1, m), shape


def compute_valid_1d_patterns(m, n):  # return all possible m:n patterns in a 1d vector
    # Early exit if patterns was already created.
    global valid_m4n2_1d_patterns

    if m == 4 and n == 2 and valid_m4n2_1d_patterns is not None:
        return valid_m4n2_1d_patterns
    patterns = torch.zeros(m)
    patterns[:n] = 1
    valid_patterns = torch.tensor(list(set(permutations(patterns.tolist()))))
    if m == 4 and n == 2:
        valid_m4n2_1d_patterns = valid_patterns
    return valid_patterns


def mn_1d_best(matrix, m, n):  # m:n 1d structured best
    # Find all possible patterns.
    patterns = compute_valid_1d_patterns(m, n).cuda()

    # Find the best m:n pattern (sum of non-masked weights).
    mat, shape = reshape_1d(matrix, m)  # `shape` is the padded shape of matrix
    pmax = torch.argmax(torch.matmul(mat.abs(), patterns.t()), dim=1)
    mask = torch.ones_like(mat, dtype=torch.int, device='cuda').view(-1, m)
    mask[:] = patterns[pmax[:]]
    mask = mask.view(shape)

    # split the mask from size(mat) to size(matrix)
    rows, cols = matrix.size()
    mask = mask[:rows, :cols]
    return mask


def create_mask(tensor, pattern="m4n2_1d", density=0.5):  # returns a sparse mask
    # Reshape tensor and mask.
    shape = tensor.shape
    ttype = tensor.type()
    t = tensor.float().contiguous()

    # 1d-tensor
    if len(shape) == 1:
        t = t.view(1, shape[0])
        mask = mn_1d_best(t, 4, 2)
        return mask.view(shape).type(ttype)
    # 2d-tensor (K, C)
    elif len(shape) == 2:
        # linear
        t = t.view(shape[0], shape[1])
        mask = mn_1d_best(t, 4, 2)
        return mask.view(shape).type(ttype)
    # 3d-tensor (K, C, R)
    elif len(shape) == 3:
        # 1d convs
        t = t.permute(0, 2, 1).contiguous().view(shape[0]*shape[2], shape[1])
        mask = mn_1d_best(t, 4, 2)
        mask = mask.view(shape[0], shape[2], shape[1]).permute(0, 2, 1).contiguous()
        return mask.view(shape).type(ttype)
    # 4d-tensor (K, C, R, S)
    elif len(shape) == 4:
        """
        # transformers (bmm)
        t = t.view(shape[0]*shape[1]*shape[2], shape[3])
        func = getattr(sys.modules[__name__], pattern, None)
        mask = func(t, density)
        return mask.view(shape).type(ttype)
        """
        # 2d convs
        t = t.permute(2, 3, 0, 1).contiguous().view(shape[2]*shape[3]*shape[0], shape[1])
        mask = mn_1d_best(t, 4, 2)
        mask = mask.view(shape[2], shape[3], shape[0], shape[1]).permute(2, 3, 0, 1).contiguous()
        return mask.view(shape).type(ttype)
