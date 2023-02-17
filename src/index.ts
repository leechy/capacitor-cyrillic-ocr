import { registerPlugin } from '@capacitor/core';

import type { CapacitorOCRPlugin } from './definitions';

const CapacitorOCR = registerPlugin<CapacitorOCRPlugin>('CapacitorOCR', {
  web: () => import('./web').then(m => new m.CapacitorOCRWeb()),
});

export * from './definitions';
export { CapacitorOCR };
