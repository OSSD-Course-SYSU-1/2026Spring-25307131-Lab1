# 冒泡排序实现（Python作业标准示例，直接复制即可）
def bubble_sort(arr):
    n = len(arr)
    # 遍历所有数组元素
    for i in range(n):
        # 最后i个元素已经排序完成，无需再比较
        for j in range(0, n - i - 1):
            # 若当前元素大于下一个元素，交换位置
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr

# 测试代码（验证排序效果）
if __name__ == "__main__":
    test_arr = [64, 34, 25, 12, 22, 11, 90]
    print("排序前的数组:", test_arr)
    sorted_arr = bubble_sort(test_arr)
    print("排序后的数组:", sorted_arr)