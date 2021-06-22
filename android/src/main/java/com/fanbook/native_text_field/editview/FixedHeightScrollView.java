package com.fanbook.native_text_field.editview;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.ScrollView;

import com.fanbook.native_text_field.Utils;

public class FixedHeightScrollView extends ScrollView {

    private boolean scrollable = true;
    private int fixedHeight;

    public FixedHeightScrollView(Context context) {
        this(context, 0);
    }

    public FixedHeightScrollView(Context context, int fixedHeight) {
        this(context, null);
        if (fixedHeight != 0) {
            this.fixedHeight = Utils.dip2px(context, fixedHeight);
        }
    }

    public FixedHeightScrollView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public FixedHeightScrollView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setScrollable(boolean scrollable) {
        this.scrollable = scrollable;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        if (fixedHeight == 0){
            super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        } else {
            super.onMeasure(widthMeasureSpec, MeasureSpec.makeMeasureSpec(fixedHeight, MeasureSpec.EXACTLY));
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        if (scrollable) {
            return super.onTouchEvent(ev);
        } else {
            return true;
        }
    }
}