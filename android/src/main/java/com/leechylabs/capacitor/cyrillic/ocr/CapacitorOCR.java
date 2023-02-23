package com.leechylabs.capacitor.cyrillic.ocr;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.util.Base64;

import androidx.annotation.NonNull;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.googlecode.tesseract.android.ResultIterator;
import com.googlecode.tesseract.android.TessBaseAPI;
import org.json.JSONException;

public class CapacitorOCR {

    public JSObject recognize(String base64Image, @NonNull JSArray languages, String orientation, Context context) throws JSONException {
        TessBaseAPI tessApi;

        String language = languages.join("+").replace("\"", "");
        Bitmap bitmapImage = base64ToBitmap(base64Image);
        if (!orientation.equals("up")) {
            Float degree = (orientation.equals("down"))  ?  180f : (orientation.equals("right")) ? 90f : -90f;
            bitmapImage = rotateBitmap(bitmapImage, degree);
        }

        // Initialize the API with the default path and languages
        tessApi = new TessBaseAPI();
        try {
            tessApi.init(context.getFilesDir().getPath(), language, TessBaseAPI.OEM_TESSERACT_ONLY);
        } catch (IllegalArgumentException e) {
            tessApi.recycle();
            return null;
        }

        // Convert the bas64 image to bitmap
        tessApi.setImage(bitmapImage);

        // call
        String text = tessApi.getUTF8Text();
        JSArray lines = new JSArray();
        String lastLineText = "";
        Rect lastLineBBox = new Rect();
        JSArray words = new JSArray();

        // Then get just iterator with the results
        final ResultIterator iterator = tessApi.getResultIterator();
        iterator.begin();
        do {
            // when a new line is started
            if (iterator.isAtBeginningOf(TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE)) {
                // set the words for the previous line if any
                if (words.length() > 0) {
                    // add words and line props to the lines
                    lines.put(getResultObj(lastLineText, lastLineBBox, words));
                    // and clean the words array
                    words = new JSArray();
                }
                // get text and BBox for the following line
                lastLineText = iterator.getUTF8Text(TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE);
                lastLineBBox = iterator.getBoundingRect(TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE);
            }

            // words
            String wordText = iterator.getUTF8Text(TessBaseAPI.PageIteratorLevel.RIL_WORD);
            Rect wordBBox = iterator.getBoundingRect(TessBaseAPI.PageIteratorLevel.RIL_WORD);
            words.put(getResultObj(wordText, wordBBox, new JSArray()));
        } while (iterator.next(TessBaseAPI.PageIteratorLevel.RIL_WORD));

        // finally the last line should be added
        if (words.length() > 0) {
            lines.put(getResultObj(lastLineText, lastLineBBox, words));
        }

        // construct  the final results
        JSObject result = new JSObject();
        result.put("text", text);
        result.put("lines", lines);

        // release Tesseract API
        tessApi.recycle();

        return result;
    }

    public static Bitmap base64ToBitmap(String base64) {
        byte[] byteArr = Base64.decode(base64, 0);
        return BitmapFactory.decodeByteArray(byteArr, 0, byteArr.length);
    }

    public Bitmap rotateBitmap(Bitmap original, float degrees) {
        int x = original.getWidth();
        int y = original.getHeight();
        Matrix matrix = new Matrix();
        matrix.preRotate(degrees);
        Bitmap rotatedBitmap = Bitmap.createBitmap(original , 0, 0, original .getWidth(), original .getHeight(), matrix, true);
        return rotatedBitmap;
    }

    public JSObject getResultObj(String text, Rect rect, JSArray words) {
        // create js output
        JSObject result = new JSObject();

        // text line
        result.put("text", text);

        // construct BBex
        JSObject bBox = new JSObject();
        bBox.put("x0", rect.left);
        bBox.put("y0", rect.top);
        bBox.put("x1", rect.right);
        bBox.put("y1", rect.bottom);
        result.put("bbox", bBox);

        // don't have proper confidence number for now
        result.put("confidence", 0.8);

        // set words if they were passed
        if (words.length() > 0) {
            result.put("words", words);
        }

        return result;
    }
}
