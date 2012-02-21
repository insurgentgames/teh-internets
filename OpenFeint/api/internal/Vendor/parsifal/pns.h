/* generated code. do not edit. */
/*===========================================================================
  Parsifal XML Parser namespace definition
  Copyright (c) 2007 Benjamin Allan

  This header allows parsifal to be moved to any prefix
  by rerunning makeNamespaceHeader.sh.

  We choose to do this by redefining the public symbols found in the compiled
  binary rather than changing every line in the library source.

  If _PNS is not defined in the compiler flags, this file does nothing.

  To use the prefix in parsifal development mode (defining new 
  public functions), do the following:

  (.) Complete the regular build with the options you need to obtain a 
  library (.a or .so) with the symbols that need prefixes added.

  (.) Regenerate pns.h with the new prefix, e.g.
	makeNamespaceHeader.sh libparsifal.a > include/libparsifal/pns.h babel_
   
  (.) To build with the prefix support:
      make clean; ./configure CFLAGS=-D_PNS {otheroptions}; make; make install

  Regular libparsifal and one in an alternate namespace should 
  be non-overlapping at link time with the exception of stricmp replacements. 
  We're assuming stricmp won't be changing across libparsifal versions.
  We're assuming libparsifal defines no functions starting with _.

  We should incorporate prefix into the library name, but this requires
  significant autotools regeneration to achieve.

  DISCLAIMER
  ----------

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  Merchantability or fitness for a particular purpose. Please use it AT
  YOUR OWN RISK.
===========================================================================*/

#ifndef PNS__H
#define PNS__H

#ifdef _PNS
#define PNS_PREFIX babel_

#define BufferedIStream_AppendBytes babel_BufferedIStream_AppendBytes
#define BufferedIStream_EncodeBuffer babel_BufferedIStream_EncodeBuffer
#define BufferedIStream_Free babel_BufferedIStream_Free
#define BufferedIStream_Init babel_BufferedIStream_Init
#define BufferedIStream_Peek babel_BufferedIStream_Peek
#define BufferedIStream_ResetBuf babel_BufferedIStream_ResetBuf
#define Latin1ToUtf8 babel_Latin1ToUtf8
#define Utf8ToUtf8 babel_Utf8ToUtf8
#define XMLHTable_Create babel_XMLHTable_Create
#define XMLHTable_Destroy babel_XMLHTable_Destroy
#define XMLHTable_Enumerate babel_XMLHTable_Enumerate
#define XMLHTable_Insert babel_XMLHTable_Insert
#define XMLHTable_Lookup babel_XMLHTable_Lookup
#define XMLHTable_Remove babel_XMLHTable_Remove
#define XMLIsNameChar babel_XMLIsNameChar
#define XMLIsNameStartChar babel_XMLIsNameStartChar
#define XMLNormalizeBuf babel_XMLNormalizeBuf
#define XMLParser_Create babel_XMLParser_Create
#define XMLParser_Free babel_XMLParser_Free
#define XMLParser_GetContextBytes babel_XMLParser_GetContextBytes
#define XMLParser_GetCurrentColumn babel_XMLParser_GetCurrentColumn
#define XMLParser_GetCurrentEntity babel_XMLParser_GetCurrentEntity
#define XMLParser_GetCurrentLine babel_XMLParser_GetCurrentLine
#define XMLParser_GetNamedItem babel_XMLParser_GetNamedItem
#define XMLParser_GetPrefixMapping babel_XMLParser_GetPrefixMapping
#define XMLParser_GetPublicID babel_XMLParser_GetPublicID
#define XMLParser_GetSystemID babel_XMLParser_GetSystemID
#define XMLParser_GetVersionString babel_XMLParser_GetVersionString
#define XMLParser_Parse babel_XMLParser_Parse
#define XMLParser_SetExternalSubset babel_XMLParser_SetExternalSubset
#define xmlMemdup babel_xmlMemdup
#define XMLStringbuf_Append babel_XMLStringbuf_Append
#define XMLStringbuf_AppendCh babel_XMLStringbuf_AppendCh
#define XMLStringbuf_Free babel_XMLStringbuf_Free
#define XMLStringbuf_Init babel_XMLStringbuf_Init
#define XMLStringbuf_InitUsePool babel_XMLStringbuf_InitUsePool
#define XMLStringbuf_SetLength babel_XMLStringbuf_SetLength
#define XMLStringbuf_ToString babel_XMLStringbuf_ToString
#define XMLVector_Append babel_XMLVector_Append
#define XMLVector_Create babel_XMLVector_Create
#define XMLVector_Free babel_XMLVector_Free
#define XMLVector_Get babel_XMLVector_Get
#define XMLVector_InsertBefore babel_XMLVector_InsertBefore
#define XMLVector_Remove babel_XMLVector_Remove
#define XMLVector_Replace babel_XMLVector_Replace
#define XMLVector_Resize babel_XMLVector_Resize
#define XMLPool_Alloc babel_XMLPool_Alloc
#define XMLPool_Create babel_XMLPool_Create
#define XMLPool_Free babel_XMLPool_Free
#define XMLPool_FreePool babel_XMLPool_FreePool
#define DTDValidate_Characters babel_DTDValidate_Characters
#define DTDValidate_EndElement babel_DTDValidate_EndElement
#define DTDValidate_IgnorableWhitespace babel_DTDValidate_IgnorableWhitespace
#define DTDValidate_StartElement babel_DTDValidate_StartElement
#define XMLParser_CreateDTDValidator babel_XMLParser_CreateDTDValidator
#define XMLParser_FreeDTDValidator babel_XMLParser_FreeDTDValidator
#define XMLParser_ParseValidateDTD babel_XMLParser_ParseValidateDTD
#endif /* _PNS */
#endif /* PNS__H */
