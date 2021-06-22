package com.fanbook.native_text_field.messages;

import java.util.Map;

public class CreationParams {

    private double width;
    private double height;
    private String text;
    private TextStyle textStyle;
    private String placeHolder;
    private TextStyle placeHolderStyle;
    private String textAlign;
    private int maxLength;
    private boolean done;
    private String keyboardType;
    private String allowRegExp;
    private boolean readOnly;
    private int maxLines;

    public CreationParams(Map<String, Object> params) {
        Object width = params.get("width");
        this.width = getValue(width);
        if (this.width == 0) this.width = 200;

        Object height = params.get("height");
        this.height = getValue(height);
        if (this.height == 0) this.height = 40.0;

        Object text = params.get("text");
        this.text = text == null ? "" : (String) text;

        Object textStyle = params.get("textStyle");
        if (textStyle != null) {
            Map<String, Object> tsMap = (Map<String, Object>) textStyle;
            this.textStyle = new TextStyle(tsMap);
        } else {
            this.textStyle = new TextStyle();
        }

        Object placeHolder = params.get("placeHolder");
        this.placeHolder = placeHolder == null ? "" : (String) placeHolder;

        Object placeHolderStyle = params.get("placeHolderStyle");
        if (placeHolderStyle != null) {
            Map<String, Object> tsMap = (Map<String, Object>) placeHolderStyle;
            this.placeHolderStyle = new TextStyle(tsMap);
        } else {
            this.placeHolderStyle = new TextStyle();
        }

        Object textAlign = params.get("textAlign");
        this.textAlign = textAlign == null ? "" : (String) textAlign;

        Object maxLength = params.get("maxLength");
        this.maxLength = maxLength == null ? 5000 : (int) maxLength;
        if (this.maxLength == 0) this.maxLength = 5000;

        Object done = params.get("done");
        this.done = done != null && (boolean) done;

        Object keyboardType = params.get("keyboardType");
        this.keyboardType = keyboardType == null ? "" : (String) keyboardType;

        Object allowRegExp = params.get("allowRegExp");
        this.allowRegExp = allowRegExp == null ? "" : (String) allowRegExp;

        Object readOnly = params.get("readOnly");
        this.readOnly = readOnly != null && (boolean) readOnly;

        Object maxLines = params.get("maxLines");
        this.maxLines = maxLines == null ? 1 : (int) maxLines;
    }

    private double getValue(Object obj) {
        double ret = 0;
        if (obj == null) return ret;
        if (obj instanceof Integer)  return ((Integer) obj).doubleValue();
        if (obj instanceof Double) return (Double) obj;
        return ret;
    }

    public double getWidth() {
        return width;
    }

    public double getHeight() {
        return height;
    }

    public String getText() {
        return text;
    }

    public TextStyle getTextStyle() {
        return textStyle;
    }

    public String getPlaceHolder() {
        return placeHolder;
    }

    public TextStyle getPlaceHolderStyle() {
        return placeHolderStyle;
    }

    public String getTextAlign() {
        return textAlign;
    }

    public int getMaxLength() {
        return maxLength;
    }

    public boolean isDone() {
        return done;
    }

    public String getKeyboardType() {
        return keyboardType;
    }

    public String getAllowRegExp() {
        return allowRegExp;
    }

    public boolean isReadOnly() {
        return readOnly;
    }

    public int getMaxLines() {
        return maxLines;
    }

    @Override
    public String toString() {
        return "CreationParams{" +
                "width=" + width +
                ", height=" + height +
                ", text='" + text + '\'' +
                ", textStyle=" + textStyle +
                ", placeHolder='" + placeHolder + '\'' +
                ", placeHolderStyle=" + placeHolderStyle +
                ", textAlign='" + textAlign + '\'' +
                ", maxLength=" + maxLength +
                ", done=" + done +
                ", keyboardType='" + keyboardType + '\'' +
                ", allowRegExp='" + allowRegExp + '\'' +
                ", readOnly=" + readOnly +
                ", maxLines=" + maxLines +
                '}';
    }
}
