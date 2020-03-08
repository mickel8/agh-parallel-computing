from numba import njit
import numpy as np


@njit(parallel=True, fastmath=True)
def run(size):
    mx1 = np.random.rand(size, size)
    mx2 = np.random.rand(size, size)
    return np.dot(mx1, mx2)
