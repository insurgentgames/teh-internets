////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// 
///  Copyright 2009 Aurora Feint, Inc.
/// 
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///  
///  	http://www.apache.org/licenses/LICENSE-2.0
///  	
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
/// 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "OFResourceLoader.h"
#include "OFXmlDocument.h"
#include "OFXmlElement.h"
#include "OFViewDataSetter.h"

void OFResourceLoader::loadIntoView(NSString* resourceTypeName, OFXmlDocument* resourceXml, OFViewDataSetter* setter)
{
	[resourceXml pushNextScope:[resourceTypeName UTF8String]];
	while(OFPointer<OFXmlElement> nextElement = [resourceXml readNextElement])
	{
		if(nextElement->hasChildren())
		{
			OFAssert(0, "Resource field has child fields. Skipping. This is not currently supported. (%@)\r\n", resourceTypeName);
			continue;
		}

		NSString* fieldName = nextElement->getName();
		
		if(!setter->isValidField(fieldName))
		{
			OFAssert(0, "Skipping invalid field %@.%@", resourceTypeName, fieldName);
			continue;
		}
		
		setter->setField(fieldName, nextElement->getValue());
	}

	[resourceXml popScope];
}