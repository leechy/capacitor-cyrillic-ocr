import { WebPlugin } from '@capacitor/core';

import type { CapacitorOCRPlugin } from './definitions';

export class CapacitorOCRWeb extends WebPlugin implements CapacitorOCRPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
