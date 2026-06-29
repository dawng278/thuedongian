import { create, XMLBuilder } from 'xmlbuilder2';

export class XmlBuilderService {
  buildDocument(
    rootName: string,
    attrs: Record<string, string>,
  ): XMLBuilder {
    return create({ version: '1.0', encoding: 'UTF-8' }).ele(rootName, attrs);
  }

  toString(document: XMLBuilder, prettyPrint = true): string {
    return document.end({ prettyPrint });
  }
}
