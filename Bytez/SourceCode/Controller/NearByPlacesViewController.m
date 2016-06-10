//
//  NearByPlacesViewController.m
//  Bytez
//
//  Created by HMSPL on 05/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "NearByPlacesViewController.h"
#import "DataHandler.h"
#import "NearByPlaceTableViewCell.h"
#import "SettingsViewController.h"
#import "BytezSessionHandler.h"
@interface NearByPlacesViewController ()<UITextFieldDelegate>

@end

@implementation NearByPlacesViewController
{
    __weak IBOutlet UIButton *btnDone;
    __weak IBOutlet UITextField *txtFieldSearch;
    __weak IBOutlet UITableView *tableViewNearByPlaces;
    NSMutableArray * locationList;
    BOOL isSearchKeyPresent;
    NSMutableArray * addLocationArray;
    NSMutableArray * arrayTableContents;
    UIRefreshControl *refreshControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NearByPlacesResponseDTO *addLocation=[[NearByPlacesResponseDTO alloc]init];
    addLocation.placeName=@"Add location";
    addLocation.vicinity=@"Add Number";
    addLocationArray=[NSMutableArray arrayWithObjects:addLocation, nil];
    arrayTableContents=[NSMutableArray array];
    [txtFieldSearch setDelegate:self];
   // txtFieldSearch.autocorrectionType=UITextAutocorrectionTypeDefault;
    locationList=[[NSMutableArray alloc]init];
    [tableViewNearByPlaces setDataSource:self];
    [tableViewNearByPlaces setDelegate:self];
    [tableViewNearByPlaces setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    btnDone.layer.cornerRadius=5.0f;
    [self startUpdatingLocation];
    // Do any additional setup after loading the view.
  
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnDoneAction:(id)sender {
    [self goBack];
}

#pragma mark Location Delegate methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    [self.locationManger stopUpdatingLocation];
    self.locationManger=nil;
    CLLocation *currentLocation = [locations objectAtIndex:0];
    if (currentLocation!=nil) {
        NSString *lat=[NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
        NSString *longi=[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
        [DataHandler getMyNearbyPlacesWithLat:lat
                                    longitude:longi successHandler:^(id response) {
                                        locationList=response;
                                        arrayTableContents=[NSMutableArray arrayWithArray:response];
                                        [tableViewNearByPlaces reloadData];
                                    } failureHandler:^(NSError *error) {
                                        
                                    }];
        
          //changes
       
//        [DataHandler getMyNearbyPlacesWithLat:lat longitude:longi radius:[[BytezSessionHandler Instance] bytezRadius] successHandler:^(id response) {
//            locationList=response;
//            arrayTableContents=[NSMutableArray arrayWithArray:response];
//            [tableViewNearByPlaces reloadData];
//
//        } failureHandler:^(NSError *error) {
//            
//        }];
        
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc]initWithTitle:@"Unable to find your current location" message:@"" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark TableViewDelegate and Datasource methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"MyReuseIdentifier";
    NearByPlaceTableViewCell *cell;
    cell= (NearByPlaceTableViewCell *)[tableViewNearByPlaces dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NearByPlaceTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
   
    cell.placeDetail=[arrayTableContents objectAtIndex:indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayTableContents count];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate selectedLocation:[arrayTableContents objectAtIndex:indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark Text field delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *textFieldString=[NSMutableString stringWithString:textField.text];
    [textFieldString replaceCharactersInRange:range withString:string];
    NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz 0123456789"] invertedSet];
    NSString *trimmedReplacement = [[textFieldString componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
    if ([trimmedReplacement stringByTrimmingCharactersInSet:nonNumberSet].length == textFieldString.length || [string isEqualToString:@""]) {
            arrayTableContents=[NSMutableArray arrayWithArray:locationList];
            NSLog(@"--->%@",locationList);
            if ([textFieldString isEqualToString:@""]) {
                isSearchKeyPresent=NO;
            }
            else {
                isSearchKeyPresent=YES;
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber *number = [formatter numberFromString:textFieldString];
                if (number){
                    // it's a number
                    NSPredicate *numberPredicate = [NSPredicate predicateWithFormat:@"vicinity contains[c] %@",textFieldString];
                    [arrayTableContents filterUsingPredicate:numberPredicate];
                } else {
                    // it's not a number
                    NSString *nameformatString = [NSString stringWithFormat:@"placeName contains[c] '%@'", textFieldString];
                    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:nameformatString];
                    [arrayTableContents filterUsingPredicate:namePredicate];
                }
            }
            [tableViewNearByPlaces reloadData];
            return YES;
        }
        else{
            return NO;
        }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self goBack];
     return YES;
}
-(void)goBack
{
    NearByPlacesResponseDTO *selectedLocation=[[NearByPlacesResponseDTO alloc]init];
    selectedLocation.placeName=[txtFieldSearch text];
    //selectedLocation.vicinity=[txtFieldSearch text];
    selectedLocation.vicinity= selectedLocation.placeName;
    [self.delegate selectedLocation:selectedLocation];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
