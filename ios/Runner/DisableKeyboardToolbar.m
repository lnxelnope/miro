#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation UIView (DisableFlutterKeyboardToolbar)

/// Swizzle inputAccessoryView only for FlutterTextInputView
/// to remove the native "Done" toolbar above the keyboard.
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"FlutterTextInputView");
        if (!cls) return;

        SEL sel = @selector(inputAccessoryView);
        Method original = class_getInstanceMethod(cls, sel);

        IMP replacement = imp_implementationWithBlock(^(id _self) {
            return nil;
        });

        if (original) {
            method_setImplementation(original, replacement);
        } else {
            class_addMethod(cls, sel, replacement, "@@:");
        }
    });
}

@end
