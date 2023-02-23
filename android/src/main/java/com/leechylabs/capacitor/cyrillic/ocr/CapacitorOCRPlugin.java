package com.leechylabs.capacitor.cyrillic.ocr;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import org.json.JSONException;

@CapacitorPlugin(name = "CapacitorOCR")
public class CapacitorOCRPlugin extends Plugin {

    private CapacitorOCR implementation = new CapacitorOCR();

    @PluginMethod
    public void recognize(PluginCall call) throws JSONException {
        // retrieve the params
        String base64Image = call.getString("base64Image");
        String orientation = call.getString("orientation");
        JSArray languages = call.getArray("languages", new JSArray(new String[] { "eng" }));

        // recognition
        JSObject results = implementation.recognize(base64Image, languages, orientation, getContext());

        // sending results to the app
        call.resolve(results);
    }
}
