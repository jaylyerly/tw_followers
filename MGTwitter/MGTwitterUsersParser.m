//
//  MGTwitterUsersParser.m
//  MGTwitterEngine
//
//  Created by Matt Gemmell on 19/02/2008.
//  Copyright 2008 Instinctive Code.
//

#import "MGTwitterUsersParser.h"

@interface MGTwitterUsersParser (PrivateMethods)


@end

@implementation MGTwitterUsersParser

/*
- (id)initWithXML:(NSData *)theXML delegate:(NSObject <MGTwitterParserDelegate> *)theDelegate
connectionIdentifier:(NSString *)theIdentifier requestType:(MGTwitterRequestType)reqType
     responseType:(MGTwitterResponseType)respType
{
    if ((
         self = [super initWithXML:theXML
                          delegate:theDelegate
              connectionIdentifier:theIdentifier
                       requestType:reqType
                      responseType:respType]
         )) {
    }
    
    return self;
}
*/

#pragma mark NSXMLParser delegate methods


- (void)parser:(NSXMLParser *)theParser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"Started element: %@ (%@)", elementName, attributeDict);
    [self setLastOpenedElement:elementName];
    
    if ([elementName isEqualToString:@"user"]) {
        // Make new entry in parsedObjects.
        NSMutableDictionary *newNode = [NSMutableDictionary dictionaryWithCapacity:0];
        [parsedObjects addObject:newNode];
        currentNode = newNode;
    } else if ([elementName isEqualToString:@"status"]) {
        // Add an appropriate dictionary to current node.
        NSMutableDictionary *newNode = [NSMutableDictionary dictionaryWithCapacity:0];
        [currentNode setObject:newNode forKey:elementName];
        currentNode = newNode;
    } else if ([elementName isEqualToString:@"next_cursor"]) {
        self.tmpNextCursor = [NSMutableString string];
    } else if ([elementName isEqualToString:@"previous_cursor"]) {
        self.tmpPreviousCursor = [NSMutableString string];
    } else if (currentNode) {
        // Create relevant name-value pair.
        [currentNode setObject:[NSMutableString string] forKey:elementName];
    }
}

- (void)parser:(NSXMLParser *)theParser foundCharacters:(NSString *)characters
{
    //NSLog(@"Found characters: %@", characters);
    // Append found characters to value of lastOpenedElement in currentNode.
    if (lastOpenedElement && currentNode) {
        [[currentNode objectForKey:lastOpenedElement] appendString:characters];
    }
    if (self.tmpNextCursor){
        [self.tmpNextCursor appendString:characters];
    }
    if (self.tmpPreviousCursor){
        [self.tmpPreviousCursor appendString:characters];
    }
}


- (void)parser:(NSXMLParser *)theParser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    [super parser:theParser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
    
    if ([elementName isEqualToString:@"status"]) {
        currentNode = [parsedObjects lastObject];
    } else if ([elementName isEqualToString:@"next_cursor"]) {
        [parsedObjects addObject:@{@"next_cursor":self.tmpNextCursor}];
        NSLog(@"WJL >> got tmpNextCursor:%@",self.tmpNextCursor);
        self.tmpNextCursor = nil;
    } else if ([elementName isEqualToString:@"previous_cursor"]) {
        [parsedObjects addObject:@{@"previous_cursor":self.tmpPreviousCursor}];
        self.tmpPreviousCursor = nil;
    } else if ([elementName isEqualToString:@"user"]) {
        [self addSource];
        currentNode = nil;
    }
    
}



@end
