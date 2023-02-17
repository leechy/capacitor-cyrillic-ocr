export interface CapacitorOCRPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
