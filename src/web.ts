import { WebPlugin } from '@capacitor/core';

import type {
  CapacitorOCROptions,
  CapacitorOCRPlugin,
  CapacitorOCRResult,
} from './definitions';

export class CapacitorOCRWeb extends WebPlugin implements CapacitorOCRPlugin {
  async recognize(options: CapacitorOCROptions): Promise<CapacitorOCRResult[]> {
    console.log(
      'This plugin is not intended to work in the browser. Please use tesseract.js (https://tesseract.projectnaptha.com/) if you want the functionality.',
      options,
    );
    return [];
  }
}
