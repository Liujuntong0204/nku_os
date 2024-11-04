#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>
#define MAX_ORDER 14

free_area_t free_area1[MAX_ORDER+1];

#define free_list(property) (free_area1[(property)].free_list)
#define nr_free(property) (free_area1[(property)].nr_free)

static void
buddy_system_init(void) {
    for(int i=0;i<MAX_ORDER+1;i++)
    {
    list_init(&(free_area1[i].free_list));
     free_area1[i].nr_free = 0;
    }
}

static void
buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    p=base;
    size_t remain=n;
    while(remain!=0)
    {
        int order=0;
        while (remain >= (1 << (order))) {
        order++;
        }
        order--;
        p->property=order;
        SetPageProperty(p);
        free_area1[order].nr_free+=1;
        list_add(&(free_area1[order].free_list), &(p->page_link));
        p=p+(1<<(order));
        remain=remain-(1<<(order));
    }   
}
    

static void split_page(int order) {
    if(list_empty(&(free_area1[order].free_list))) {
        split_page(order + 1);
    }
    struct Page *page = NULL;
    list_entry_t *le = &(free_area1[order].free_list);
    le = list_next(le);
    page= le2page(le, page_link);
    list_del(&(page->page_link));
    free_area1[order].nr_free-=1;
    size_t n = 1 << (order - 1);
    struct Page *p = page + n;
    page->property = order-1;
    p->property = order-1;
    SetPageProperty(p);
    SetPageProperty(page);
    list_add(&(free_area1[order-1].free_list),&(page->page_link));
    list_add(&(page->page_link),&(p->page_link));
    free_area1[order-1].nr_free += 2;
    return;
}


static struct Page *
buddy_system_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > (1 << (MAX_ORDER))) {
        return NULL;
    }
    int order=0;
    while (n > (1 << (order))) {
        order++;
    }
    int i=order;
    for (;i<=MAX_ORDER;i++)
    {
        if(!list_empty(&(free_area1[i].free_list)))
        {
            break;
        }
    }
    if(i==MAX_ORDER+1)
    {
        return NULL;
    }
    if(list_empty(&(free_area1[order].free_list)))
    {
         split_page(order + 1);
    }
    if(list_empty(&(free_area1[order].free_list)))
    {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &(free_area1[order].free_list);
    le = list_next(le);
    page= le2page(le, page_link);
    list_del(&(page->page_link));
    ClearPageProperty(page);
    free_area1[order].nr_free-=1;
    return page;
}

// 添加页到链表数组 页大小为1<<order
static void add_page(struct Page *base, int order)
{
    if (list_empty(&(free_area1[order].free_list))) {
        list_add(&(free_area1[order].free_list), &(base->page_link));
        cprintf("加入空链表\n");
    } 
    else {
        list_entry_t* le = &(free_area1[order].free_list);
        while ((le = list_next(le)) != &(free_area1[order].free_list)) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                cprintf("page1的地址为%016lx:\n",page);
                cprintf("base1的地址为：%016lx\n",base);
                break;
            } else if (list_next(le) == &(free_area1[order].free_list)) {
                list_add(le, &(base->page_link));
                cprintf("page2的地址为%016lx:\n",page);
                cprintf("base2的地址为：%016lx\n",base);
                break;
            }
        }
        cprintf("加入非空链表\n");
    }
}

//递归合并空页
static void merge_page(struct Page *base, int order)
{
    cprintf("进入merge\n");
    if(order == MAX_ORDER)
    {
        return;
    }

    // 标记，每次递归只能合并一次
    int has_merge=0;


    // 和前页合并
    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &(free_area1[order].free_list)) {
        cprintf("进入第一个if\n\n");
        struct Page *p = le2page(le, page_link);
        cprintf("p的地址为%016lx:\n",p);
        cprintf("base的地址为：%016lx\n",base);
        cprintf("p的property为：%d\n",p->property);
        if (p + (1<<(p->property)) == base) {
            cprintf("进入merge 和前页合并\n");
            has_merge = 1;
            p->property += 1;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
            //合并后从当前链表中删除，添加到更大的链表中
            list_del(&(base->page_link));
            free_area1[order].nr_free -= 2;
            add_page(base,order+1);
            free_area1[order+1].nr_free += 1;
        }
    }

    // 和后页合并
    le = list_next(&(base->page_link));
    if (le != &(free_area1[order].free_list)) {
        struct Page *p = le2page(le, page_link);
        if (has_merge == 0 && base + (1<<(base->property)) == p ) {
            cprintf("进入merge 和后页合并\n");
            has_merge = 1;
            base->property += 1;
            ClearPageProperty(p);
            list_del(&(p->page_link));
            //合并后从当前链表中删除，添加到更大的链表中
            list_del(&(base->page_link));
            free_area1[order].nr_free -= 2;
            add_page(base,order+1);
            free_area1[order].nr_free += 1;
        }
    }
    if(has_merge == 1) //成功merge则递归调用上一级merge
    {
        merge_page(base,order+1);
    }
    return;
}


static void
buddy_system_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    
    int order = 0;
    while(n!=(1<<order))
    {
        order++;
    }
    cprintf("当前order为： %d \n",order);
    base->property = order;
    SetPageProperty(base);

    // 将新的空页添加到对应链表
    add_page(base, order);
    free_area1[order].nr_free += 1;

    // 尝试合并
    merge_page(base, order);
}

static size_t
buddy_system_nr_free_pages(void) {
    size_t num = 0;
    for(int i=0;i<=MAX_ORDER;i++)
    {
        num+=free_area1[i].nr_free<<i;
    }
    return num;
}

// static void
// basic_check(void) {
//     struct Page *p0, *p1, *p2;
//     p0 = p1 = p2 = NULL;
//     assert((p0 = alloc_page()) != NULL);
//     assert((p1 = alloc_page()) != NULL);
//     assert((p2 = alloc_page()) != NULL);

//     assert(p0 != p1 && p0 != p2 && p1 != p2);
//     assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

//     assert(page2pa(p0) < npage * PGSIZE);
//     assert(page2pa(p1) < npage * PGSIZE);
//     assert(page2pa(p2) < npage * PGSIZE);

//     cprintf("success!!");

//     // list_entry_t free_list_store = free_list;
//     // list_init(&free_list);
//     // assert(list_empty(&free_list));

//     // unsigned int nr_free_store = nr_free;
//     // nr_free = 0;

//     // assert(alloc_page() == NULL);

//     // free_page(p0);
//     // free_page(p1);
//     // free_page(p2);
//     // assert(nr_free == 3);

//     // assert((p0 = alloc_page()) != NULL);
//     // assert((p1 = alloc_page()) != NULL);
//     // assert((p2 = alloc_page()) != NULL);

//     // assert(alloc_page() == NULL);

//     // free_page(p0);
//     // assert(!list_empty(&free_list));

//     // struct Page *p;
//     // assert((p = alloc_page()) == p0);
//     // assert(alloc_page() == NULL);

//     // assert(nr_free == 0);
//     // free_list = free_list_store;
//     // nr_free = nr_free_store;

//     // free_page(p);
//     // free_page(p1);
//     // free_page(p2);
// }
static void basic_check(void) {
    struct Page *p0, *p1, *p2;

    cprintf("Starting buddy_system_basic_check...\n");
    for(int i=0;i<=MAX_ORDER;i++)
    {
        cprintf(" 第 %d 阶有 %d 个空闲块 \n",i,free_area1[i].nr_free);
    }

    p0=buddy_system_alloc_pages(7);
    p1=buddy_system_alloc_pages(8);
    p2=buddy_system_alloc_pages(8);

    for(int i=0;i<=MAX_ORDER;i++)
    {
        cprintf(" 第 %d 阶有 %d 个空闲块 \n",i,free_area1[i].nr_free);
    }
    buddy_system_free_pages(p1,8);
    buddy_system_free_pages(p2,8);
    buddy_system_free_pages(p0,8);
    for(int i=0;i<=MAX_ORDER;i++)
    {
        cprintf(" 第 %d 阶有 %d 个空闲块 \n",i,free_area1[i].nr_free);
    }

}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
buddy_system_check(void) {
    // int count = 0, total = 0;
    // list_entry_t *le = &free_list;
    // while ((le = list_next(le)) != &free_list) {
    //     struct Page *p = le2page(le, page_link);
    //     assert(PageProperty(p));
    //     count ++, total += p->property;
    // }
    // assert(total == nr_free_pages());

    basic_check();

    // struct Page *p0 = alloc_pages(5), *p1, *p2;
    // assert(p0 != NULL);
    // assert(!PageProperty(p0));
    

    // list_entry_t free_list_store = free_list;
    // list_init(&free_list);
    // assert(list_empty(&free_list));
    // assert(alloc_page() == NULL);

    // unsigned int nr_free_store = nr_free;
    // nr_free = 0;

    // free_pages(p0 + 2, 3);
    // assert(alloc_pages(4) == NULL);
    // assert(PageProperty(p0 + 2) && p0[2].property == 3);
    // assert((p1 = alloc_pages(3)) != NULL);
    // assert(alloc_page() == NULL);
    // assert(p0 + 2 == p1);

    // p2 = p0 + 1;
    // free_page(p0);
    // free_pages(p1, 3);
    // assert(PageProperty(p0) && p0->property == 1);
    // assert(PageProperty(p1) && p1->property == 3);

    // assert((p0 = alloc_page()) == p2 - 1);
    // free_page(p0);
    // assert((p0 = alloc_pages(2)) == p2 + 1);

    // free_pages(p0, 2);
    // free_page(p2);

    // assert((p0 = alloc_pages(5)) != NULL);
    // assert(alloc_page() == NULL);

    // assert(nr_free == 0);
    // nr_free = nr_free_store;

    // free_list = free_list_store;
    // free_pages(p0, 5);

    // le = &free_list;
    // while ((le = list_next(le)) != &free_list) {
    //     struct Page *p = le2page(le, page_link);
    //     count --, total -= p->property;
    // }
    // assert(count == 0);
    // assert(total == 0);
}
//这个结构体在
const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = buddy_system_check,
};