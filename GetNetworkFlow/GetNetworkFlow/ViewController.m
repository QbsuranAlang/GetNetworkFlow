//
//  ViewController.m
//  GetNetworkFlow
//
//  Created by 聲華 陳 on 2014/11/26.
//  Copyright (c) 2014年 Qbsuran Alang. All rights reserved.
//

#import "ViewController.h"
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>
#include <arpa/inet.h>
#include <net/if_dl.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)flow:(id)sender {
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return;
    }
    
    uint32_t iBytes     = 0;
    uint32_t oBytes     = 0;
    uint32_t allFlow    = 0;
    uint32_t wifiIBytes = 0;
    uint32_t wifiOBytes = 0;
    uint32_t wifiFlow   = 0;
    uint32_t wwanIBytes = 0;
    uint32_t wwanOBytes = 0;
    uint32_t wwanFlow   = 0;
    struct timeval time;
    char buffer[256];
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        
        if (ifa->ifa_data == 0)
            continue;
        
        // Not a loopback device.
        // network flow
        if (strncmp(ifa->ifa_name, "lo", 2))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
            allFlow = iBytes + oBytes;
        }
        
        //wifi flow
        if (!strcmp(ifa->ifa_name, "en0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            wifiIBytes += if_data->ifi_ibytes;
            wifiOBytes += if_data->ifi_obytes;
            wifiFlow    = wifiIBytes + wifiOBytes;
            time = if_data->ifi_lastchange;
        }
        
        //3G and gprs flow
        if (!strcmp(ifa->ifa_name, "pdp_ip0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            wwanIBytes += if_data->ifi_ibytes;
            wwanOBytes += if_data->ifi_obytes;
            wwanFlow    = wwanIBytes + wwanOBytes;
        }
    }
    freeifaddrs(ifa_list);
    
    time_t t = time.tv_sec;
    struct tm *timeinfo = localtime(&t);
    strftime (buffer, 256, "%Y/%m/%d %H:%M:%S", timeinfo);
    
    NSString *s = [NSString stringWithFormat:
                   @"iBytes: %u bytes\n"
                   "oBytes: %u bytes\n"
                   "allFlow: %u bytes\n"
                   "wifiIBytes: %u bytes\n"
                   "wifiOBytes: %u bytes\n"
                   "wifiFlow: %u bytes\n"
                   "wwanIBytes: %u bytes\n"
                   "wwanOBytes: %u bytes\n"
                   "wwanFlow: %u bytes\n"
                   "Time: %s\n",
                   iBytes, oBytes, allFlow, wifiIBytes, wifiOBytes, wifiFlow, wwanIBytes, wwanOBytes, wwanFlow, buffer];
    self.message.text = s;
    NSLog(@"%@", s);
}

- (IBAction)inOut:(id)sender {
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    int WiFiSent = 0;
    int WiFiReceived = 0;
    int WWANSent = 0;
    int WWANReceived = 0;
    
    NSString *name = @"";
    
    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
                }
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                    WWANReceived+=networkStatisc->ifi_ibytes;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    
    NSString *s = [NSString stringWithFormat:
                   @"WiFiSent: %d bytes\n"
                   "WiFiReceived: %d bytes\n"
                   "WWANSent: %d bytes\n"
                   "WWANReceived: %d bytes\n",
                   WiFiSent, WiFiReceived, WWANSent, WWANReceived];
    self.message.text = s;
    
    NSLog(@"%@", s);
}
@end
