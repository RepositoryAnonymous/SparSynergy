# SparSynergy

## Project Overview
SparSynergy is an open-source RTL implementation that includes Tensor Core [1], Sparse Tensor Core[2], BitWave[3], and SparSynergy. This project is based on the article *"SparSynergy: Unlocking Flexible and Efficient DNN Acceleration through Multi-Level Sparsity"* and aims to provide flexible and efficient solutions for deep neural network acceleration.

## Features
- **Tensor Core**: Efficient dense matrix multiplication support. It is the baseline for evaluating the performance gains achieved through sparsity exploitation.
- **Sparse Tensor Core**: Optimization for sparse tensor computations to enhance performance. Sparse Tensor Core represents value-level sparse accelerators, offering fixed sparse patterns.
- **BitWave**: Accelerated data processing using bit-column-serial computation. BitWave represents bit-level sparse accelerators that provides insights into the advantages of our multi-level sparsity approach.
- **SparSynergy (Ours)**: Multi-Level Sparsity Support. Facilitating flexible acceleration of deep learning models.

----

References:

[1] NVIDIA, “Nvidia tesla v100 gpu architecture,” tech. rep., 2017

[2] C. Jack et al., “Nvidia a100 tensor core gpu: Performance and innovation,” IEEE Micro, vol. 41, no. 2, pp. 29–35, 2021.

[3] S. Man et al., “Bitwave: Exploiting column-based bit-level sparsity for deep learning acceleration,” in HPCA, pp. 732–746, 2024.

