# capacitor-cyrillic-ocr

OCR plugin with Cyrillic support (MLKit Vision on iOS and Tesseract4Android)

I was using amazing Capacitor plugin @pantrist/capacitor-plugin-ml-kit-text-recognition. It's based on Google's MLKit Vision API. It works great, but it doesn't support Cyrillic languages. So I decided to create new plugin based on Tesseract for Android and MLKit Vision for iOS.

## Install

```bash
npm install capacitor-cyrillic-ocr
npx cap sync
```

## API

<docgen-index>

- [`recognize(...)`](#recognize)
- [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### recognize(...)

```typescript
recognize(options: CapacitorOCROptions) => Promise<CapacitorOCRResult[]>
```

| Param         | Type                                                                |
| ------------- | ------------------------------------------------------------------- |
| **`options`** | <code><a href="#capacitorocroptions">CapacitorOCROptions</a></code> |

**Returns:** <code>Promise&lt;CapacitorOCRResult[]&gt;</code>

---

### Interfaces

#### CapacitorOCRResult

| Prop             | Type                            |
| ---------------- | ------------------------------- |
| **`text`**       | <code>string</code>             |
| **`lines`**      | <code>CapacitorOCRLine[]</code> |
| **`confidence`** | <code>number</code>             |

#### CapacitorOCRLine

| Prop             | Type                                                          |
| ---------------- | ------------------------------------------------------------- |
| **`text`**       | <code>string</code>                                           |
| **`bbox`**       | <code><a href="#capacitorocrbbox">CapacitorOCRBBox</a></code> |
| **`words`**      | <code>CapacitorOCRWord[]</code>                               |
| **`confidence`** | <code>number</code>                                           |

#### CapacitorOCRBBox

| Prop     | Type                |
| -------- | ------------------- |
| **`x0`** | <code>number</code> |
| **`y0`** | <code>number</code> |
| **`x1`** | <code>number</code> |
| **`y1`** | <code>number</code> |

#### CapacitorOCRWord

| Prop             | Type                                                          |
| ---------------- | ------------------------------------------------------------- |
| **`text`**       | <code>string</code>                                           |
| **`bbox`**       | <code><a href="#capacitorocrbbox">CapacitorOCRBBox</a></code> |
| **`confidence`** | <code>number</code>                                           |

#### CapacitorOCROptions

| Prop              | Type                                             |
| ----------------- | ------------------------------------------------ |
| **`base64Image`** | <code>string</code>                              |
| **`orientation`** | <code>'up' \| 'down' \| 'left' \| 'right'</code> |
| **`languages`**   | <code>string[]</code>                            |

</docgen-api>
