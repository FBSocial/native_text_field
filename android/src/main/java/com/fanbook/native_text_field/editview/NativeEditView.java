package com.fanbook.native_text_field.editview;

import android.content.Context;
import android.text.Editable;
import android.text.InputFilter;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.fanbook.native_text_field.Utils;
import com.fanbook.native_text_field.messages.CreationParams;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

import static com.fanbook.native_text_field.NativeTextFieldPlugin.VIEW_TYPE_ID;

public class NativeEditView implements PlatformView, MethodChannel.MethodCallHandler {
    private static final String TAG = "NativeEditView";

    private final Context mContext;
    private final EditText mEditText;
    private MethodChannel methodChannel;

    private final int DEFAULT_HEIGHT = 40;

    public NativeEditView(Context context, int viewId, Map<String, Object> creationParams, BinaryMessenger
            messenger) {
        mContext = context;
        mEditText = new EditText(context);

//        int resId = context.getResources().getIdentifier("NativeEditTextTheme", "style", mContext.getPackageName());
//        mEditText = new EditText(new ContextThemeWrapper(context, resId));
        // 修改textSelectHandle等样式颜色等，可以直接在app模块的主题中设置相关属性
        // 如果还需要修改图片的话，可以使用上面注释中的方式
        initViewParams(creationParams);
        initMethodChannel(messenger, viewId);
    }

    private void initViewParams(Map<String, Object> params) {
        CreationParams creationParams = new CreationParams(params);
        Log.d(TAG, "initViewParams: " + creationParams);
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT);
        mEditText.setMinLines(1);
        mEditText.setMaxLines(creationParams.getMaxLines());
        mEditText.setGravity(Utils.string2TextAlignment(creationParams.getTextAlign()));
        mEditText.setLayoutParams(layoutParams);

        double textSize = creationParams.getTextStyle().getFontSize();
        double textHeightRatio = (float) creationParams.getTextStyle().getHeight();

        double verticalPaddingDp = ((DEFAULT_HEIGHT - textSize) / 2);
        int verticalPadding = Utils.dip2px(mContext, (float) (verticalPaddingDp - (textHeightRatio - 1) * textSize)) / 2;
        mEditText.setPadding(Utils.dip2px(mContext, 2), verticalPadding, Utils.dip2px(mContext, 4), verticalPadding);
        mEditText.setInputType(Utils.string2InputType(creationParams.getKeyboardType()));

        mEditText.setWidth(Utils.dip2px(this.mEditText.getContext(), (float) creationParams.getWidth()));
        mEditText.setText(creationParams.getText());
        if (creationParams.getText() != null && creationParams.getText().length() > 0) {
            mEditText.setSelection(creationParams.getText().length());
        }
        mEditText.setTextColor((int) creationParams.getTextStyle().getColor());
        mEditText.setTextSize((float) textSize);
        mEditText.setEnabled(!creationParams.isReadOnly());

        Utils.setTextLineHeight(mEditText, (float) textHeightRatio);

        mEditText.setHint(creationParams.getPlaceHolder());
        mEditText.setHintTextColor((int) creationParams.getPlaceHolderStyle().getColor());
        InputFilter[] filters = {new InputFilter.LengthFilter(creationParams.getMaxLength())};
        mEditText.setFilters(filters);
        mEditText.setBackground(null);
        mEditText.setLongClickable(true);
    }

    private void initMethodChannel(BinaryMessenger messenger, int viewId) {
        methodChannel = new MethodChannel(messenger, VIEW_TYPE_ID + "_" + viewId);
        methodChannel.setMethodCallHandler(this);
        mEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                Log.d(TAG, "beforeTextChanged: " + s.toString() + " start:" + start + ", count:" + count + ", after:" + after);
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                Log.d(TAG, "onTextChanged: " + s.toString() + " start:" + start + ", count:" + count);
                methodChannel.invokeMethod("updateText", s.toString());
            }

            @Override
            public void afterTextChanged(Editable s) {
                Log.d(TAG, "afterTextChanged: " + s.toString());
            }
        });

        mEditText.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                Log.d(TAG, "onFocusChange: " + hasFocus);
                methodChannel.invokeMethod("updateFocus", hasFocus);
            }
        });
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.d(TAG, "onMethodCall: " + call.method);
        switch (call.method) {
            case "setText":
                handleSetText(call, result);
                break;
            case "updateFocus":
                handleUpdateFocus(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public View getView() {
        return mEditText;
    }

    @Override
    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }

    private void handleSetText(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String content = (String) call.arguments;
        mEditText.setText(content);
        mEditText.setSelection(content.length());
        result.success(null);
    }

    private void handleUpdateFocus(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Boolean focus = (Boolean) call.arguments;
        Log.d(TAG, "handleUpdateFocus: flutter -> android: " + focus);
        if (focus) {
            mEditText.requestFocus();
        } else {
            mEditText.clearFocus();
            Utils.hideSoftKeyboard(mContext, mEditText);
        }
        result.success(null);
    }
}
