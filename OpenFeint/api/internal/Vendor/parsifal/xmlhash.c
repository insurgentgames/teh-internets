#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "xmlhash.h"
#include "xmlcfg.h"  /* for xmlMemdup */

#define BUCK3T ((XMLHTABLEBUCKET*)table->bucket)
#define NOD3POOLSZ (table->size/4)
#define NOD3MARK rand8

static unsigned char rand8[] = {
     41, 35,190,132,225,108,214,174,
     82,144, 73,241,187,233,235,179,
    166,219, 60,135, 12, 62,153, 36,
     94, 13, 28,  6,183, 71,222, 18,
     77,200, 67,139, 31,  3, 90,125,
      9, 56, 37, 93,212,203,252,150,
    245, 69, 59, 19,137, 10, 50, 32,
    154, 80,238, 64,120, 54,253,246,
    158,220,173, 79, 20,242, 68,102,
    208,107,196, 48,161, 34,145,157,
    218,176,202,  2,185,114, 44,128,
    126,197,213,178,234,201,204, 83,
    191,103, 45,142,131,239, 87, 97,
    255,105,143,205,209, 30,156, 22,
    230, 29,240, 74,119,215,232, 57,
     51,116,244,159,164, 89, 53,207,
    211, 72,117,217, 42,229,192,247,
     43,129, 14, 95,  0,141,123,  5,
     21,  7,130, 24,112,146,100, 84,
    206,177,133,248, 70,106,  4,115,
     47,104,118,250, 17,136,121,254,
    216, 40, 11, 96, 61,151, 39,138,
    194,  8,165,193,140,169,149,155,
    168,167,134,181,231, 85, 78,113,
    226,180,101,122, 99, 38,223,109,
     98,224, 52, 63,227, 65, 15, 27,
    243,160,127,170, 91,184, 58, 16,
     76,236, 49, 66,124,228, 33,147,
    175,111,  1, 23, 86,198,249, 55,
    189,110, 92,195,163,152,199,182,
     81, 25, 46,188,148, 75, 88,210,
    172, 26,162,237,251,221,186,171};

/*
	Hashes a string to produce an unsigned short, which should be
	sufficient for most purposes.
*/
static unsigned hash(XMLCH *str, size_t n, size_t *keylen) 
{	
	XMLCH *key = str;
	if (n < 256) {
		unsigned char h = 0;
		while (*str) { h = rand8[h ^ *str]; str++; }
		if (keylen) *keylen = str - key;
		return h % n;
	} else {
		int h;
		unsigned char h1, h2;
		
		if (*str == 0) return 0;
		h1 = *str; h2 = *str + 1;
		str++;
		while (*str) {
			h1 = rand8[h1 ^ *str];
			h2 = rand8[h2 ^ *str];
			str++;
		}

		/* h is in range 0..65535 */
		h = ((int)h1 << 8)|(int)h2;
		/* use division method to scale */
		if (keylen) *keylen = str - key;
		return h % n;
	}
}

/* 
	NewNode() is 'malloc' for nodes from nodepools (used in insert). 
	table->nodes[cnodepools] is an array of (NOD3POOLSZ*table->blocksize) 
	blocks (void*) into which table->freenode holds current free pointer.
	freenode is result from FreeNode() call when
	freenode->next != NOD3MARK
	Note that currently nodepools don't shrink at all, this is the easiest
	way to achieve pointers staying valid. Some sort of pattern
	checking for totally unused pool in FreeNode could do the trick...
*/ 
static void *NewNode(LPXMLHTABLE table)
{		
	void *n;
	
	if (!table->freenode) {
		table->nodes = (void**)realloc(table->nodes, (table->cnodepools+1) * sizeof *table->nodes);
		if (!table->nodes) return NULL;
		table->nodes[table->cnodepools] = malloc(NOD3POOLSZ*table->blocksize);
		n = table->nodes[table->cnodepools++];
		if (!n) return NULL;
		
		table->freenode = (char*)n+table->blocksize;
		((XMLHTABLEBUCKET*)table->freenode)->next = NOD3MARK;	
	}
	else {

		n = table->freenode;

		if (((XMLHTABLEBUCKET*)n)->next == NOD3MARK) { /* get next free node from the pool */
			table->freenode = (char*)table->freenode+table->blocksize;
			if (table->freenode == (char*)table->nodes[table->cnodepools-1] + (NOD3POOLSZ*table->blocksize))
				table->freenode = NULL; /* last node check (pretty ugly) */
			else
				((XMLHTABLEBUCKET*)table->freenode)->next = NOD3MARK;
		}
		else 	
			table->freenode = ((XMLHTABLEBUCKET*)n)->next;
	}
	return n;
}

static void FreeNode(LPXMLHTABLE table, void *node)
{
	void *n = table->freenode;
	table->freenode = node;
	((XMLHTABLEBUCKET*)node)->next = n;
}

static LPXMLHTABLE Create(LPXMLHTABLE table, size_t size)
{
	table = (LPXMLHTABLE)malloc(sizeof *table);	
	if (!table) return NULL;
	table->size = size;
	table->table = (void**)malloc(size * sizeof *table->table);
	if (!table->table) {
		free(table);
		return NULL;
	}
	for (size=0; size<table->size; size++) 
		(table->table)[size] = NULL;
	table->nodes = NULL;
	table->freenode = NULL;
	table->cnodepools = 0;
	return table;
}

LPXMLHTABLE XMLAPI XMLHTable_Create(LPXMLHTABLE table, size_t size)
{	
	table = Create(table, size);
	if (table) {
		PRVNAM3_SETDT(table, void*, sizeof(void*));
		table->flags = 0;
	}
	return table;
}

void XMLAPI *XMLHTable_Insert(LPXMLHTABLE table, XMLCH *key, void *data)
{
	size_t keylen;
	unsigned val;
	
	if (table->flags&XMLHTABLEFLAG_NOCOPYKEY) {
		val = hash(key, table->size, NULL);
		keylen = (size_t)(-1); 
	}
	else val = hash(key, table->size, &keylen); /* note that we allow zerolength key */

	if (!(table->table)[val]) {
		(table->table)[val] = NewNode(table);
		table->bucket = (table->table)[val];
		if (!table->bucket) return NULL;
		
		if (keylen == (size_t)(-1))
			BUCK3T->key = key;
		else if (!(BUCK3T->key = xmlMemdup(key, keylen+1))) 
			return NULL;
		
		BUCK3T->next = NULL;
		if (table->flags&XMLHTABLEFLAG_NOPTRDATA)
			return (void*)XMLHTable_GetData(table, table->bucket);
		*((void**)XMLHTable_GetData(table, table->bucket)) = data;
		return data;
	}

	/*
		This spot in the table is already in use. See if the current string
		has already been inserted:
	*/
	for (table->bucket = (table->table)[val]; table->bucket; table->bucket = BUCK3T->next) {
		if (!strcmp((const char*)key, (const char*)BUCK3T->key)) {
			if (table->flags&XMLHTABLEFLAG_NOPTRDATA)
				return (data) ? data : /* signal 'replaced'/'no duplicates allowed' -flag */
					(void*)XMLHTable_GetData(table, table->bucket);
			else {
				void **d = (void**)XMLHTable_GetData(table, table->bucket);
				void *old = *d;
				*d = data;
				return old;
			}
		}
	}

	/*
		This key must not be in the table yet.  We'll add it to the head of
		the list at this spot in the hash table.
	*/
	table->bucket = NewNode(table);
	if (!table->bucket) return NULL;
	if (keylen == (size_t)(-1))
		BUCK3T->key = key;
	else if (!(BUCK3T->key = xmlMemdup(key, keylen+1))) 
		return NULL;
	
	BUCK3T->next = (table->table)[val];
	(table->table)[val] = table->bucket;
	if (table->flags&XMLHTABLEFLAG_NOPTRDATA)
		return (void*)XMLHTable_GetData(table, table->bucket);
	*((void**)XMLHTable_GetData(table, table->bucket)) = data;
	return data;
}

void XMLAPI *XMLHTable_Lookup(LPXMLHTABLE table, XMLCH *key)
{
	unsigned val = hash(key, table->size, (size_t)NULL);
	if (!(table->table)[val]) return NULL;

	for (table->bucket = (table->table)[val]; table->bucket; table->bucket = BUCK3T->next) {
		if (!strcmp((const char*)key, (const char*)BUCK3T->key))
			return (table->flags&XMLHTABLEFLAG_NOPTRDATA) ?
				(void*)XMLHTable_GetData(table, table->bucket) :
				*((void**)XMLHTable_GetData(table, table->bucket));      
	}
	return NULL;
}

void XMLAPI *XMLHTable_Remove(LPXMLHTABLE table, XMLCH *key)
{
	unsigned val = hash(key, table->size, (size_t)NULL);
	XMLHTABLEBUCKET *last = NULL;

	if (!(table->table)[val]) return NULL;

	/*
		Traverse the list, keeping track of the previous node in the list.
		When we find the node to delete, we set the previous node's next
		pointer to point to the node after ourself instead.  We then delete
		the key from the present node, and return a pointer to the data it
		contains.
	*/

	for (last = NULL, table->bucket = (table->table)[val]; table->bucket;
		last = (XMLHTABLEBUCKET*)table->bucket, table->bucket = (XMLHTABLEBUCKET*)BUCK3T->next)
	{
		if (!strcmp((const char*)key, (const char*)BUCK3T->key)) {
			void *data = (table->flags&XMLHTABLEFLAG_NOPTRDATA) ? 
				(void*)XMLHTable_GetData(table, table->bucket) :
				*((void**)XMLHTable_GetData(table, table->bucket));  

			/*
				If 'last' is NULL, it means that we need to
				delete the first node in the list. This simply consists
				of putting our own 'next' pointer in the array holding
				the head of the list.
			*/
			if (last == NULL)
				(table->table)[val] = BUCK3T->next;				     
			else 
				last->next = BUCK3T->next;   	

			if (!(table->flags&XMLHTABLEFLAG_NOCOPYKEY)) free(BUCK3T->key);
			FreeNode(table, table->bucket);
			/* note that we can return NOPTRDATA too since FreeNode doesn't
			really free the node but puts it into free list */
			return data;
		}
	}
	/* If we get here, it means we didn't find the item in the table. */
	return NULL;
}

int XMLAPI XMLHTable_Destroy(LPXMLHTABLE table, int (*func)(XMLCH *, void *, void *), int dflags)
{	
	int ret=0;
	size_t i=0; /* i also marks 'already enumerated' for FORREUSE */

	if (!(dflags&XMLHTABLEDFLAG_NOENUM)) {
		if (!func) {
			if (!(table->flags&XMLHTABLEFLAG_NOCOPYKEY)) { 
				for (i=0; i<table->size; i++) /* we have to enumerate and free the keys */
					if ((table->table)[i]) {
						for (table->bucket = (table->table)[i]; table->bucket; 
							table->bucket = BUCK3T->next) free(BUCK3T->key);
						(table->table)[i] = NULL; /* clear the table for possible reuse */
					}
			}
		}
		else {
			if (dflags&XMLHTABLEDFLAG_DEFUSERDATA) table->userdata = table;
			ret = XMLHTable_Enumerate(table, func);
		}
	}
	if (dflags&XMLHTABLEDFLAG_FORREUSE) {
		if (table->nodes && table->cnodepools && table->freenode != table->nodes[0]) {			
			if (!i) { /* already enumerated? */
				for (i=0; i<table->size; i++) 
					if ((table->table)[i]) (table->table)[i] = NULL;
			}
			/* cnodepools=1 will resize array accordingly on next realloc */
			while (table->cnodepools>1) free(table->nodes[--table->cnodepools]);
			table->freenode = table->nodes[0];
			((XMLHTABLEBUCKET*)table->freenode)->next = NOD3MARK;	
		}
		return ret;
	}
	else {
		if (table->nodes && table->cnodepools) {
			do { 
				free(table->nodes[--table->cnodepools]); 
			} while (table->cnodepools);
		}
		free(table->nodes);
		free(table->table);
		free(table);
	}
	return ret;
}

/*
	Simply invokes the function given as the second parameter for each
	node in the table, passing it the key and the associated data +
	userdata (can be pointer to destination table if Enumerate is used
	for copying hashtable for example).
*/
int XMLAPI XMLHTable_Enumerate(LPXMLHTABLE table, int (*func)(XMLCH *, void *, void *))
{
	unsigned i, ret;
	void *next;

	for (i=0; i<table->size; i++) {
		if ((table->table)[i]) {
			for (table->bucket = (table->table)[i]; table->bucket; table->bucket = next) {
				next = BUCK3T->next;
				ret = func(BUCK3T->key, (table->flags&XMLHTABLEFLAG_NOPTRDATA) ?
					(void*)XMLHTable_GetData(table, table->bucket) :
					*((void**)XMLHTable_GetData(table, table->bucket)), 
					table->userdata);
				if (ret) {
					if (ret!=XMLHTABLEDFLAG_FREETHISKEY) return ret;
					free(BUCK3T->key);
				}
			}
		}
	}
	return 0;
}

#undef BUCK3T
#undef NOD3POOLSZ
#undef NOD3MARK

