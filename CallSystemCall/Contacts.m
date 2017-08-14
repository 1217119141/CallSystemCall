//
//  Contacts.m
//  ceshi
//
//  Created by iOS开发 on 17/3/28.
//  Copyright © 2017年 iOS开发. All rights reserved.
//

#import "Contacts.h"
//获取设配号
#define Is_up_Ios_9             [[UIDevice currentDevice].systemVersion floatValue] >= 9.0

@interface Contacts()<ABPeoplePickerNavigationControllerDelegate,CNContactPickerDelegate>
//需要显示的控制器
@property (nonatomic, strong) UIViewController *viewController;
@end

@implementation Contacts

/**
 *单例创建 避免多次创建
 */
+ (instancetype)contactsManager {
    static id contactsManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contactsManager = [[Contacts alloc] init];
    });
    return contactsManager;
}
/**
 *类方法初始化调用系统通讯录
 *viewController：所要在那个界面显示
 *block：选中的值的代码块
 */
+ (void)judgeAddressBookPowerWithUIViewController:(UIViewController *)viewController contactsBlock:(contactsBlock)block
{
    [[self contactsManager] judgeAddressBookPowerWithUIViewController:viewController contactsBlock:block];
}
/**
 *对象方法初始化调用系统通讯录
 *viewController：所要在那个界面显示
 *block：选中的值的代码块
 */
- (void)judgeAddressBookPowerWithUIViewController:(UIViewController *)viewController contactsBlock:(contactsBlock)block
{
    self.viewController = viewController;
    ///获取通讯录权限，调用系统通讯录
    [self checkAddressBookAuthorization:^(bool isAuthorized, bool isUp_ios_9) {
        if (isAuthorized) {
            [self callAddressBook:isUp_ios_9];
        }else {
            NSLog(@"请到设置>隐私>通讯录打开本应用的权限设置");
        }
    }];
    self.contactsBlock = block;
}
/**
 *调用系统通讯录权限的判断
 */
- (void)checkAddressBookAuthorization:(void(^)(bool isAuthorized,bool isUp_ios_9))block
{
    if (Is_up_Ios_9) {
        CNContactStore * contactStore = [[CNContactStore alloc]init];
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * __nullable error) {
                if (error)
                {
                    NSLog(@"Error: %@", error);
                }
                else if (!granted)
                {
                    
                    block(NO,YES);
                }
                else
                {
                    block(YES,YES);
                }
            }];
        }
        else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized){
            block(YES,YES);
        }
        else {
            NSLog(@"请到设置>隐私>通讯录打开本应用的权限设置");
        }
    }else {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
        
        if (authStatus == kABAuthorizationStatusNotDetermined)
        {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error)
                    {
                        NSLog(@"Error: %@", (__bridge NSError *)error);
                    }
                    else if (!granted)
                    {
                        
                        block(NO,NO);
                    }
                    else
                    {
                        block(YES,NO);
                    }
                });
            });
        }else if (authStatus == kABAuthorizationStatusAuthorized)
        {
            block(YES,NO);
        }else {
            NSLog(@"请到设置>隐私>通讯录打开本应用的权限设置");
        }
    }
}
/**
 *根据设备号不同调用系统通讯录
 */
- (void)callAddressBook:(BOOL)isUp_ios_9 {
    if (isUp_ios_9) {
        CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
        contactPicker.delegate = self;
        contactPicker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
        [self.viewController presentViewController:contactPicker animated:YES completion:nil];
    }else {
        ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
        peoplePicker.peoplePickerDelegate = self;
        [self.viewController presentViewController:peoplePicker animated:YES completion:nil];
        
    }
}
#pragma mark -- CNContactPickerDelegate
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    CNPhoneNumber *phoneNumber = (CNPhoneNumber *)contactProperty.value;
    [self.viewController dismissViewControllerAnimated:YES completion:^{
        /// 联系人
        NSString *name = [NSString stringWithFormat:@"%@%@",contactProperty.contact.familyName,contactProperty.contact.givenName];
        /// 电话
        NSString *phoneNum = phoneNumber.stringValue;
        //去除手机号中间的-
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"-"withString:@""];
        if (self.contactsBlock) {
            self.contactsBlock(name,phoneNum);
        }
    }];
}

#pragma mark -- ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    ABMultiValueRef valuesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex index = ABMultiValueGetIndexForIdentifier(valuesRef,identifier);
    CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef,index);
    CFStringRef anFullName = ABRecordCopyCompositeName(person);
    
    [self.viewController dismissViewControllerAnimated:YES completion:^{
        /// 联系人
        NSString *name = [NSString stringWithFormat:@"%@",anFullName];
        /// 电话
        NSString *phoneNum = (__bridge NSString*)value;
        //去除手机号中间的-
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"-"withString:@""];
        if (self.contactsBlock) {
            self.contactsBlock(name,phoneNum);
        }
    }];
}
@end
