export interface CapacitorOCROptions {
  base64Image: string;
  orientation: 'up' | 'down' | 'left' | 'right';
  languages?: string[];
}

export interface CapacitorOCRResult {
  text: string;
  lines: CapacitorOCRLine[];
  confidence?: number;
}

export interface CapacitorOCRLine {
  text: string;
  bbox: CapacitorOCRBBox;
  words?: CapacitorOCRWord[];
  confidence?: number;
}

export interface CapacitorOCRWord {
  text: string;
  bbox: CapacitorOCRBBox;
  confidence?: number;
}

export interface CapacitorOCRBBox {
  x0: number;
  y0: number;
  x1: number;
  y1: number;
}

export interface CapacitorOCRPlugin {
  recognize(options: CapacitorOCROptions): Promise<CapacitorOCRResult[]>;
}
