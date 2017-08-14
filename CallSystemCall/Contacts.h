//
//  Contacts.h
//  ceshi
//
//  Created by iOS开发 on 17/3/28.
//  Copyright © 2017年 iOS开发. All rights reserved.
//

#import <Foundation/Foundation.h>
/// iOS 9前的框架
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
/// iOS 9的新框架
#import <ContactsUI/ContactsUI.h>
/** 定义代码块返回选中的人的姓名和手机号 */
typedef void(^contactsBlock)(NSString *name,NSString *phoneNumber);

@interface Contacts : NSObject
/** 定义传值代码块 */
@property (nonatomic, copy) contactsBlock contactsBlock;
/** 
 *类方法初始化调用系统通讯录
 *viewController：所要在那个界面显示
 *block：选中的值的代码块
 */
+ (void)judgeAddressBookPowerWithUIViewController:(UIViewController *)viewController contactsBlock:(contactsBlock)block;

@end
