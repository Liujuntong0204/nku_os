### OS_LAB2实验报告

组员：刘俊彤，刘玉菡，孙启森

#### 实验目标
本实验旨在深入理解操作系统中的物理内存管理机制，具体包括连续物理内存分配的 First-Fit 和 Best-Fit 算法，以及拓展练习中的 Buddy System 分配算法。通过编程实现和调试这些内存分配算法，掌握物理内存分配的基本原理和优化策略。

---

### 练习1：First-Fit 连续物理内存分配算法

#### 实现过程
#### 1. `default_init` 函数

该函数负责初始化空闲内存链表和空闲页计数器。

```c
static void default_init(void) {
    list_init(&free_list); // 初始化空闲链表
    nr_free = 0;           // 初始化空闲页计数器
}
```

------

#### 2. `default_init_memmap` 函数

该函数用于初始化一块连续的物理内存页，并将其加入空闲链表中。

```c
static void default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = p->property = 0; // 清空页的标志和属性
        set_page_ref(p, 0);         // 设置引用计数为 0
    }
    base->property = n;             // 将该块的大小设置为 n 页
    SetPageProperty(base);          // 设置该页为内存块的起始页
    nr_free += n;                   // 更新系统中的空闲页数
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link)); // 空闲链表为空时，直接插入该块
    } else {
        list_entry_t *le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page *page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link)); // 按照地址顺序插入链表
                break;
            }
        }
        if (le == &free_list) {
            list_add(&free_list, &(base->page_link)); // 如果未找到合适位置，插入链表末尾
        }
    }
}
```

##### 实现细节：

1. **初始化每一页**：
   - 通过 `for` 循环对 `base` 开始的 `n` 页进行初始化，确保这些页没有被其他进程占用。`assert(PageReserved(p))` 用于确保每一页都是有效的内存。
   - 设置 `p->flags = 0` 和 `p->property = 0`，清除页的标志位和属性，确保它们处于空闲状态。
   - `set_page_ref(p, 0)` 设置页的引用计数为 0，表示该页没有被使用。
2. **设置内存块的属性**：
   - `base->property = n` 将该内存块的大小设置为 `n`，表示该内存块有 `n` 页的连续内存。
   - 使用 `SetPageProperty(base)` 标记该页为内存块的起始页，便于后续管理。
3. **插入到空闲链表**：
   - 如果空闲链表为空，则直接将该块插入链表。
   - 如果链表不为空，则按照内存地址的顺序遍历链表，找到合适的位置将该块插入链表，以保持链表的有序性。

------

#### 3. `default_alloc_pages` 函数

该函数用于分配指定数量的连续页，如果找到合适的内存块，则返回该块的起始地址。

```c
static struct Page *default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL; // 如果空闲页数不足，返回 NULL
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) { // 找到一个大小合适的块
            page = p;
            break;
        }
    }
    if (page != NULL) {
        list_del(&(page->page_link)); // 从链表中删除该块
        if (page->property > n) {     // 如果块大于请求大小
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);       // 更新剩余块的属性
            list_add(&free_list, &(p->page_link)); // 将剩余块重新插入链表
        }
        nr_free -= n;                 // 更新空闲页数
        ClearPageProperty(page);      // 清除该块的属性
    }
    return page; // 返回分配的块
}
```

##### 实现细节：

1. **检查是否有足够的空闲页**：
   - 通过 `assert(n > 0)` 确保请求的页数大于 0，然后检查系统中是否有足够的空闲页。如果空闲页数不足，则返回 `NULL`，表示无法满足请求。
2. **遍历空闲链表**：
   - 使用 `while` 循环遍历空闲链表，查找第一个能够满足请求大小的块。通过 `p->property >= n` 判断当前块是否能够满足请求。
3. **处理找到的块**：
   - 如果找到合适的块，将该块从空闲链表中删除。
   - 如果块的大小大于请求的页数，则将剩余部分作为新的空闲块重新插入链表，并更新剩余块的属性。
4. **更新空闲页数和返回块**：
   - 将分配出去的页数从 `nr_free` 中减去，并清除已分配块的属性标志，表示该块已被使用。
   - 最终返回该块的起始页地址。

------

#### 4. `default_free_pages` 函数

该函数用于释放指定数量的连续页，将其重新插入空闲链表，并尝试合并相邻的块。

```C
static void default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(!PageReserved(p) && !PageProperty(p)); // 确保要释放的页是有效的
        p->flags = 0; // 清除页的标志位
        set_page_ref(p, 0); // 将引用计数重置为 0
    }
    base->property = n;       // 将该块的大小设置为 n
    SetPageProperty(base);    // 标记该页为空闲块
    nr_free += n;             // 更新空闲页数

    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *page = le2page(le, page_link);
        if (base < page) {
            list_add_before(le, &(base->page_link)); // 按照地址顺序插入链表
            break;
        }
    }
    if (le == &free_list) {
        list_add(&free_list, &(base->page_link)); // 如果未找到合适位置，插入链表末尾
    }

    // 尝试与相邻的块进行合并
    le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (p + p->property == base) { // 检查前一个块是否可以合并
            p->property += base->property; // 合并块
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
        }
    }

    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) { // 检查后一个块是否可以合并
            base->property += p->property; // 合并块
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
    }
}
```

##### 实现细节：

1. **释放页的初始化**：
   - 使用 `for` 循环遍历 `base` 到 `base + n` 的每一页，确保要释放的页是有效的，通过 `assert` 进行验证。
   - 清除页的标志位，并将引用计数重置为 0。
2. **更新块属性并插入链表**：
   - 设置块的属性 `base->property = n`，表示该块包含 `n` 页。
   - 使用 `list_add_before` 将块按照地址顺序插入到空闲链表中，确保链表的有序性。
3. **合并相邻的块**：
   - 检查前后的块是否可以与当前块合并。如果前一个块与当前块地址连续，则将它们合并为一个更大的块，并更新块的属性。
   - 同样的，检查后一个块是否可以合并，若可以，则进行合并。

#### 改进空间
- **内存碎片问题**：First-Fit 算法会优先分配靠前的内存块，这可能导致在内存使用频繁的情况下产生较多的小碎片。可以通过改进算法，比如使用 Best-Fit 或者加入内存整理机制，减少碎片化问题。
  
- **遍历效率**：当前实现中，每次分配都需要遍历整个空闲链表，如果内存使用较多，链表较长时，分配效率会降低。可以考虑使用更高效的数据结构（如平衡树）来优化查找效率。

---

### 练习2：Best-Fit 连续物理内存分配算法

#### 实现过程
Best-Fit 算法会从空闲链表中找到最小的能够满足请求的内存块进行分配，减少内存浪费。与 First-Fit 算法的主要区别在于它需要遍历整个链表以找到最佳的内存块。

`best_fit_pmm.c` 文件中的主要实现：
1. `best_fit_init`：初始化空闲链表。

2. `best_fit_init_memmap`：将空闲页加入空闲链表，并保证链表按地址顺序排列。

3. `best_fit_alloc_pages`：遍历整个空闲链表，查找能够满足请求的最小内存块进行分配，若找到合适的块，则更新链表和页属性。

   核心代码如下：

   ```c
       size_t min_size = nr_free + 1;
   
       while ((le = list_next(le)) != &free_list) {
           struct Page *p = le2page(le, page_link);
           if (p->property >= n) {
               if(p -> property < min_size)
               {
                   page = p;
                   min_size = p-> property;
               }
           }
       }
   ```

   

4. `best_fit_free_pages`：释放内存并尝试合并相邻空闲块，类似于 First-Fit 的实现。

#### 改进空间
- **时间复杂度**：Best-Fit 算法的时间复杂度较高，每次分配都需要遍历整个链表以找到最小的合适块。可以通过改进数据结构（如堆）来加速查找最小内存块。
  
- **碎片化**：虽然 Best-Fit 算法比 First-Fit 算法能更好地减少内存碎片，但它仍然可能在频繁分配和释放内存的情况下产生碎片，可以考虑结合内存整理机制进一步优化。

---

### 扩展练习1：Buddy System 分配算法

#### 设计文档
### Buddy System 分配算法

Buddy System 是一种动态内存分配算法，它将内存块划分为 2 的幂次方大小的单位进行管理。该算法通过块的合并和分裂，有效减少了内存碎片化问题。其核心思想是当分配较小块时，可以将较大块分裂成两个较小的块，而当释放内存时，会尝试与相邻的“伙伴块”合并成一个更大的块。以下是实验中 Buddy System 分配算法的实现及详细解释。

#### 核心数据结构
```c
#define MAX_ORDER 14
free_area_t free_area1[MAX_ORDER+1];
```

`free_area1` 是一个 `free_area_t` 类型的数组，数组的每个元素表示不同大小的内存块，`MAX_ORDER` 定义了最大内存块的大小为 \( 2^{14} \) 页。

```c
#define free_list(property) (free_area1[(property)].free_list)
#define nr_free(property) (free_area1[(property)].nr_free)
```

这两个宏定义分别用于访问指定 `property` （表示内存块页数的阶数）的空闲链表和该阶数上的空闲块数量。

---

#### 1. 初始化函数

**`buddy_system_init`**：初始化 Buddy System 的空闲链表，清空各阶数的空闲块计数。

```c
static void buddy_system_init(void) {
    for(int i=0; i<MAX_ORDER+1; i++) {
        list_init(&(free_area1[i].free_list)); // 初始化每阶的空闲链表
        free_area1[i].nr_free = 0; // 初始化空闲块数量为 0
    }
}
```

---

#### 2. 初始化内存映射

**`buddy_system_init_memmap`**：根据内存大小初始化内存块，将内存从大到小划分为 2 的幂次方大小的块，并加入相应的空闲链表。

```c
static void buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = p->property = 0; // 清空页面标志和属性
        set_page_ref(p, 0);
    }
    p = base;
    size_t remain = n;
    while (remain != 0) {
        int order = 0;
        while (remain >= (1 << order)) { // 计算能够适应的最大阶数
            order++;
        }
        order--;
        p->property = order; // 设置页面的阶数
        SetPageProperty(p); // 标记该页属性
        free_area1[order].nr_free += 1; // 增加该阶空闲页数量
        list_add(&(free_area1[order].free_list), &(p->page_link)); // 插入空闲链表
        p = p + (1 << order); // 移动到下一块
        remain -= (1 << order); // 减少剩余页数
    }
}
```

- **作用**：将一块连续的内存划分为合适大小的内存块，按照 2 的幂次方进行划分，并将这些内存块加入相应阶数的空闲链表中。

- **实现细节**：

  **1. 初始化每一页**：

  - 使用 `for` 循环，从 `base` 开始对每一页进行初始化。首先通过 `assert(PageReserved(p))` 确保页是有效的（已保留），防止错误的初始化操作。
  - 使用 `p->flags = 0` 和 `p->property = 0` 来清空页的标志和属性，确保该页处于空闲状态。
  - 调用 `set_page_ref(p, 0)` 将页的引用计数设置为 0，表示当前没有地方引用该页。

  **2. 划分内存块**：

  - `while (remain != 0)` 循环的目的是将内存尽可能划分为较大的块。`order` 表示当前能够分配的最大块的阶数。
  - 每次根据剩余的页数计算出当前可以分配的最大阶数块，通过 `order--` 确定可以分配的块的阶数，并设置页的属性（`p->property = order`）。

  **3. 插入空闲链表**：

  - 使用 `list_add` 将块加入对应阶数的空闲链表，并更新该阶数上的空闲块数量 `nr_free`。

- **参数**：
  
  - `base`：起始内存页的指针。
  - `n`：需要初始化的页数。

---

#### 3. 分裂块函数

**`split_page`**：将较大的内存块分裂为两个较小的块。

```c
static void split_page(int order) {
    if (list_empty(&(free_area1[order].free_list))) {
        if (order >= MAX_ORDER) {
            return; // 无法继续分裂
        }
        split_page(order + 1); // 递归分裂更大的块
    }
    struct Page *page = NULL;
    list_entry_t *le = &(free_area1[order].free_list);
    le = list_next(le);
    page = le2page(le, page_link);
    list_del(&(page->page_link));
    free_area1[order].nr_free -= 1;

    size_t n = 1 << (order - 1);
    struct Page *p = page + n;
    page->property = order - 1;
    p->property = order - 1;
    SetPageProperty(p);
    SetPageProperty(page);
    list_add(&(free_area1[order - 1].free_list), &(page->page_link)); // 添加分裂后的两个小块
    list_add(&(page->page_link), &(p->page_link));
    free_area1[order - 1].nr_free += 2;
}
```

- **作用**：将大内存块分裂成两个较小的块，以适应较小内存请求。

- **参数**：
  - `order`：需要分裂的内存块的阶数。
  
- **实现细节**：

  **1. 检查是否有可分裂的块**：

  - 通过 `list_empty` 检查当前阶数是否有可用的空闲块。如果没有，则递归调用 `split_page` 去分裂更大的块，直到找到合适的块。

  **2.  分裂大块**：

  - 找到可用的内存块后，通过 `1 << (order - 1)` 计算分裂后的块大小。
  - 然后，将该块从链表中移除，并将其分裂为两个较小的块，更新它们的属性和链表。

  **3. 将小块加入链表**：

  - 分裂后的两个块被加入到较小阶数的空闲链表中，并更新该阶数的空闲块数量。

---

#### 4. 分配内存块

**`buddy_system_alloc_pages`**：分配内存，按照 2 的幂次分配最接近请求大小的内存块。

```c
static struct Page *buddy_system_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > (1 << (MAX_ORDER))) {
        return NULL; // 请求超出最大阶数
    }
    int order = 0;
    while (n > (1 << order)) {
        order++; // 计算所需的最小阶数
    }

    int i = order;
    for (; i <= MAX_ORDER; i++) {
        if (!list_empty(&(free_area1[i].free_list))) {
            break; // 找到合适阶数的空闲块
        }
    }
    if (i == MAX_ORDER + 1) {
        return NULL; // 没有合适的空闲块
    }

    split_page(order + 1); // 尝试分裂更大块
    if (list_empty(&(free_area1[order].free_list))) {
        return NULL; // 如果仍无空闲块，返回 NULL
    }

    struct Page *page = NULL;
    list_entry_t *le = &(free_area1[order].free_list);
    le = list_next(le);
    page = le2page(le, page_link);
    list_del(&(page->page_link));
    ClearPageProperty(page);
    free_area1[order].nr_free -= 1;
    return page;
}
```

- **作用**：根据请求的页数，分配合适大小的内存块，如果没有合适的块，会尝试通过分裂更大的块来满足请求。
- **参数**：
  - `n`：请求分配的页数。
- **实现细节**：

  **1. 计算请求的最小阶数**：

  - 通过 `while` 循环，使用位移操作 `1 << order` 计算出最小能够满足请求的阶数（即最小满足请求的内存块大小）。

  **2. 查找空闲块**：

  - 从计算出的阶数 `order` 开始，逐个阶数检查对应的空闲链表，直到找到有可用内存块的阶数。如果没有找到合适的阶数，返回 `NULL`。

  **3. 块分裂**：

  - 如果当前阶数上没有空闲块，则调用 `split_page` 函数，将较大的块分裂成更小的块，以满足当前的请求。

  **4. 从链表中删除并返回页**：

  - 找到合适的块后，使用 `list_del` 将该块从链表中移除，并通过 `ClearPageProperty` 清除块的属性标记，表示该块已经分配出去。
  - 最后返回该块的页结构指针，完成内存分配。

---

#### 5. 释放内存块

**`buddy_system_free_pages`**：释放内存并尝试与相邻块合并。

```c
static void buddy_system_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(!PageReserved(p) && !PageProperty(p)); // 确保要释放的页是有效的
        p->flags = 0; // 清除页的标志
        set_page_ref(p, 0); // 将引用计数重置为 0
    }

    int order = 0;
    while (n != (1 << order)) {
        order++; // 计算该块的阶数
    }
    base->property = order; // 设置该页的阶数
    SetPageProperty(base); // 将其标记为空闲块

    add_page(base, order); // 将该块加入对应阶数的空闲链表
    free_area1[order].nr_free += 1; // 更新该阶数的空闲块数量

    merge_page(base, order); // 尝试与相邻块合并
}

```

- **作用**：将指定内存块释放并尝试与相邻块进行合并，合并后会形成更大的块，减少碎片。
- **参数**：
  
  - `base`：要释放的内存块的起始页。
  - `n`：释放的页数。
- **实现细节**：

  **1. 验证要释放的内存块**：

  - 使用 `assert` 确保要释放的页是有效的，且没有属性标志（即不属于任何内存块）。通过 `p->flags = 0` 和 `set_page_ref(p, 0)` 清除页的状态，确保它可以被正确释放。

  **2. 确定块的阶数**：

  - 使用 `while` 循环计算出块的阶数，即该块所占的页数是多少个 2 的幂次方。阶数越大，块的大小越大。
  - 因为分配页是按照2的幂次方，所以这里进行释放的n也是2的幂次方。
  
  **3. 将块加入空闲链表**：
  
  - 调用 `add_page` 函数将释放的块按照地址顺序加入对应阶数的空闲链表，并更新空闲块的数量。
  
  **4. 尝试合并相邻块**：
  
  - 调用 `merge_page` 函数，尝试将当前释放的块与相邻的块合并，形成一个更大的块，减少内存碎片。

---

#### 6. 合并块函数

**`merge_page`**：递归地合并相邻的块。

```c
static void merge_page(struct Page *base, int order) {
    if (order == MAX_ORDER) {
        return; // 已经达到最大阶数，无法继续合并
    }

    int has_merge = 0; // 标记是否成功合并

    // 检查前一个块是否可以合并
    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &(free_area1[order].free_list)) {
        struct Page *p = le2page(le, page_link);
        if (p + (1 << p->property) == base) { // 如果前一个块与当前块相邻
            has_merge = 1;
            p->property += 1; // 更新前一个块的阶数
            ClearPageProperty(base); // 清除当前块的属性
            list_del(&(base->page_link)); // 将当前块从链表中移除
            base = p; // 合并后的新基地址为前一个块
            list_del(&(base->page_link)); // 从链表中移除合并后的块
            free_area1[order].nr_free -= 2; // 更新空闲块数量
            add_page(base, order + 1); // 将合并后的块加入更高阶的链表
            free_area1[order + 1].nr_free += 1; // 更新更高阶数的空闲块数量
        }
    }

    // 检查后一个块是否可以合并
    le = list_next(&(base->page_link));
    if (le != &(free_area1[order].free_list)) {
        struct Page *p = le2page(le, page_link);
        if (has_merge == 0 && base + (1 << base->property) == p) { // 如果后一个块与当前块相邻
            has_merge = 1;
            base->property += 1; // 更新当前块的阶数
            ClearPageProperty(p); // 清除后一个块的属性
            list_del(&(p->page_link)); // 将后一个块从链表中移除
            list_del(&(base->page_link)); // 从链表中移除合并后的块
            free_area1[order].nr_free -= 2; // 更新空闲块数量
            add_page(base, order + 1); // 将合并后的块加入更高阶的链表
            free_area1[order + 1].nr_free += 1; // 更新更高阶数的空闲块数量
        }
    }

    // 如果成功合并，则递归尝试合并更高阶的块
    if (has_merge) {
        merge_page(base, order + 1); // 递归合并更高阶的块
    }
}

```

- **作用**：递归检查相邻块是否能够合并，如果相邻块可以合并，则将其合并为更大的块，并继续检查是否能够进一步合并。
- **参数**：
  
  - `base`：要合并的内存块的起始页。
  - `order`：内存块的阶数。
- **实现细节**：

  **1. 检查前一个块**：

  - 使用 `list_prev` 获取前一个块，并通过比较两个块的地址判断它们是否相邻。若相邻，则将两个块合并为一个更大的块，并更新它们的阶数。

  **2. 检查后一个块**：

  - 使用 `list_next` 获取后一个块，并判断是否与当前块相邻。若相邻，则将两个块合并，并更新阶数。

  **3. 递归合并**：

  - 如果成功合并块，则递归调用 `merge_page`，继续检查是否可以合并更高阶的块，直到无法合并为止。

---

### 扩展练习3 ：硬件的可用物理内存范围的获取方法

- 在PC架构中，BIOS固件在启动过程中会扫描系统的物理内存，并将信息传递给操作系统。

- 一些嵌入式系统或特定硬件平台会有专门的内存映射寄存器，操作系统可以直接读取这些寄存器来获取可用的物理内存范围。

- 可以通过测试算法，即手动向特定地址空间写入数据，再读回数据来得知该空间是否可用。若数据可以被正确读回，则说明该地址空间是有效的。

  

------



### 代码总结

Buddy System 的实现通过分裂和合并机制，在满足内存分配需求的同时，尽量减少了内存碎片。每个函数在系统初始化、内存分配、释放及合并等环节中都发挥了关键作用。

---



### 重要知识点

1. **内存分配算法**：First-Fit、Best-Fit 和 Buddy System 都是常见的内存分配算法，各有优缺点。实验中可以通过代码实现逻辑看到不同算法在处理内存碎片和分配效率上的差异。
  
2. **链表管理**：链表在管理内存块时起到了关键作用，掌握链表的增删查操作是理解内存管理算法的基础。
  
3. **内存碎片化**：内存碎片是内存管理中的一个重要问题，要优化内存分配算法，减少碎片化问题是核心。

4. **块的合并与分裂**：Buddy System 通过块的分裂与合并机制有效地管理内存，避免了过多的内存碎片。

---

### 实验中未涉及的OS原理知识点
1. **虚拟内存**：实验中主要关注了物理内存的管理，未涉及虚拟内存的管理机制，如页表、TLB等内容。
  
2. **内存保护与隔离**：实验未涉及操作系统中内存保护的相关内容，例如如何防止进程之间的内存访问冲突。
  
3. **内存压缩与分页**：实验中未涉及内存压缩和分页机制，这些是现代操作系统提高内存利用率的重要方法。

---

### 实验总结
通过本次实验，我们实现了 First-Fit、Best-Fit 和 Buddy System 三种内存分配算法，并通过测试验证了它们的正确性。通过编程实现这些算法，我对操作系统中的内存管理有了更深刻的理解。尤其是 Buddy System 的实现和调试，使我认识到高级内存管理算法在减少内存碎片化方面的优势。

本实验让我深入思考了如何权衡内存分配的效率与内存碎片问题，以及如何通过改进算法和数据结构来优化内存管理策略。