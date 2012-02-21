/*===========================================================================
  xmlhash.h
    see parsifal.h for copyright info
===========================================================================*/
#ifndef XMLHASH__H
#define XMLHASH__H

#include <stddef.h> /* For size_t */
#include "pns.h"

#ifndef XMLAPI
#define XMLAPI
#endif

#ifndef XMLCH_DEFINED
	#define XMLCH_DEFINED
	typedef unsigned char XMLCH;
#endif

#define XMLHTABLEFLAG_NOCOPYKEY 1 /* doesn't malloc/free key parameter to insert & remove */
#define XMLHTABLEFLAG_NOPTRDATA 2 /* internal use */

#define XMLHTABLEDFLAG_FREETHISKEY 3333 /* destroyflags: see destroy() */
#define XMLHTABLEDFLAG_DEFUSERDATA 1
#define XMLHTABLEDFLAG_NOENUM 2
#define XMLHTABLEDFLAG_FORREUSE 4

/*
	A hash table consists of an array of these buckets. Each bucket
	holds a copy of the key and a pointer to the next bucket that collided 
	with this one, if there was one.
	datatypes, sizes and offsets will be calculated by _SETDT,
	_ALIGNOF and _ALIGNUP macros.
*/

typedef struct tagXMLHTABLEBUCKET {
	XMLCH *key;
	void *next;
} XMLHTABLEBUCKET;

typedef struct tagXMLHTABLE {
	size_t size, dataoffset, blocksize, flags, cnodepools;
	void **table, **nodes;
	void *userdata, *bucket, *freenode;
	/* bucket pointer is a hack for retrieval of current key immediately 
		after _Insert or _Lookup. (can be used in datatype spesific macros etc.) */
} XMLHTABLE, *LPXMLHTABLE;

#ifdef _MSC_VER /* to get rid of windows warning C4116: */
#define PRVNAM3_ALIGNOF __alignof /* unnamed type definition in parentheses */
#else
#define PRVNAM3_ALIGNOF(t) offsetof(struct { char c; t x; }, x)
#endif
#define PRVNAM3_ALIGNUP(size,align) ( ((size) + (align) - 1) & ~((align) - 1) )

#define PRVNAM3_SETDT(table, type, sizeoftype) (\
  (table)->dataoffset = PRVNAM3_ALIGNUP(sizeof(XMLHTABLEBUCKET), PRVNAM3_ALIGNOF(type)),\
  (table)->blocksize = (table)->dataoffset + (sizeoftype)\
)

/* example of setting int via macro (of course getting Insert return value as
appropriate pointer and setting its value would work but sometimes its cleaner
not to use intermediate pointer variable).

macro for setting int type (returns 0 on failure 1 on success):

  #define XMLHTable_InsertInt(t,key,i) \
    ((!XMLHTable_Insert((t),(key),NULL)) ? 0 : (*((int*)XMLHTable_GetData((t), (t)->bucket)) = (i)), 1)

note: XMLHTable_GetData performs only pointer arithmetic on void*, you must
cast the return value appropriately.
*/

#define XMLHTable_GetData(table, bucket) ((char*)(bucket) + (table)->dataoffset)

/* LPXMLHTABLE XMLAPI XMLHTable_CreateEx(LPXMLHTABLE table, size_t size, TYPE, SIZEOFTYPE)
is a macro because TYPE isn't valid func parameter. example:
LPXMLHTABLE ht = XMLHTable_CreateEx(ht, 255, int, sizeof(int));
*/
#define XMLHTable_CreateEx(ht,s,t,st) (\
  ht = XMLHTable_Create(ht,s),\
  (!ht) ? NULL :\
  (PRVNAM3_SETDT(ht,t,st), ht->flags|=XMLHTABLEFLAG_NOPTRDATA, ht)\
)

#ifdef __cplusplus
   extern "C" {
#endif

/*
	XMLHTable_Create is used to construct the table. Returns NULL on failure.
	uses default datatype void*. See XMLHTable_CreateEx macro for using
	other data types
*/

LPXMLHTABLE XMLAPI XMLHTable_Create(LPXMLHTABLE table,size_t size);

/*
	Insert 'key' into hash table.
	Returns pointer to old data associated with the key, if any, or
	new data if the key wasn't in the table previously.
	
	If table is created using CreateEx (XMLHTABLEFLAG_NOPTRDATA is set) 
	Insert doesn't put any data into table; it just returns pointer to data memory.
	set data parameter to NULL UNLESS you want to know whether you try to replace 
	existing data, non NULL data parameter will be returned to signal old data in 
	that case meaning perhaps 'no duplicates allowed'. Of course you could call 
	lookup before insert in that case too.
	
	Returns NULL on memory failure
*/

void XMLAPI *XMLHTable_Insert(LPXMLHTABLE table, XMLCH *key, void *data);

/*
	Returns a pointer to the data associated with a key.  If the key has
	not been inserted in the table, returns NULL.
*/

void XMLAPI *XMLHTable_Lookup(LPXMLHTABLE table, XMLCH *key);

/*
	Deletes an entry from the table.  Returns a pointer to the data that
	was associated with the key so the calling code can dispose of it
	properly.
	note that if CreateEx has been used Remove still returns pointer to the
	data; in that case pointer will be INVALID when you call other XMLHTable 
	function after the remove().
	
	NULL means data with this key wasn't found.
*/

void XMLAPI *XMLHTable_Remove(LPXMLHTABLE table, XMLCH *key);

/*
	Goes through a hash table and calls the function passed to it
	for each node that has been inserted.  The function is passed
	a pointer to the key, and a pointer to the data associated
	with it. special return value XMLHTABLEFLAG_FREETHISKEY from enumerate
	will free the current key. USE THIS ONLY WHEN YOUR INTENTION IS
	TO DESTROY THE TABLE SINCE IT WILL INVALIDATE THE KEYS but not remove
	the buckets from the table. Use remove() if you want to continue
	using the table after enumerate() !!!
*/

int XMLAPI XMLHTable_Enumerate(LPXMLHTABLE table, int (*func)(XMLCH *,void *,void *));

/*
	Frees a complete table by iterating over it and freeing each node.
	the second parameter is the address of a function similar to
	function param to _Enumerate ), when spesified, function is 
	responsible for freeing the item in table. For example the
	following function removes item from table and frees char data
	associated with it:
	
	int DestroyTable(char *key, void *data, void *userdata)
	{	
		free(data);
		return XMLHTABLEDFLAG_FREETHISKEY;
	}
	
	old version which works too but is much more inefficient since
	remove() uses hash() call and relink nodes etc:
	
	XMLHTable_Remove((LPXMLHTABLE)userdata, key);
	free(data);
	return 0;
	
	if func param isn't spesified, _Destroy frees the table items
	which is suitable in situations where data isn't dynamically
	allocated and thus can't be freed.
	
	XMLHTABLEDFLAG_FREETHISKEY   return value from enumeration func
	XMLHTABLEDFLAG_DEFUSERDATA   use table as default userdata
	XMLHTABLEDFLAG_NOENUM        don't enumerate, only free the resources
	                             keys/data freeing handled elsewhere
	XMLHTABLEDFLAG_FORREUSE		 clears the table and init vars and pools
*/

int XMLAPI XMLHTable_Destroy(LPXMLHTABLE table, int (*func)(XMLCH *, void *, void *), int dflags);

#ifdef __cplusplus
   }
#endif /* __cplusplus */
#endif /* XMLHASH__H */


