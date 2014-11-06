//
//  MasterViewController.m
//  RaTimer3
//
//  Created by Riku Oja on 4.11.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AjankayttoKohde.h"
#import "OmaTableViewCell.h"

@interface MasterViewController ()

//tallennetaan kohteet yhteen arrayhin:
@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"TallennetutKohteet" ofType:@"plist"];
    //luetaan documentdirectorysta:
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"TallennetutKohteet.plist"];
    
    //kirjoittaa aloitusplistin tiedostoon:
    /*self.objects = [NSMutableArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Opetus",@"Nimi",@"256px-Common_Squirrel.jpg",@"Kuva",@NO,@"Kaytossa", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Materiaali & suunnittelu",@"Nimi",@"256px-Common_Squirrel.jpg",@"Kuva",@NO,@"Kaytossa", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Muut työt",@"Nimi",@"256px-Common_Squirrel.jpg",@"Kuva",@NO,@"Kaytossa", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Opiskelu",@"Nimi",@"256px-Common_Squirrel.jpg",@"Kuva",@NO,@"Kaytossa", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Oravien ruokinta",@"Nimi",@"256px-Common_Squirrel.jpg",@"Kuva",@NO,@"Kaytossa", nil],nil];
     [self.objects writeToFile:path atomically:YES];*/
    
    //kopioidaan documentdirectoryyn testiplist, jos käyttäjällä ei ole plistiä:
    /*NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"TallennetutKohteet" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:path error:nil];
    }*/
    //käytetäänkin suoraan NSArray writetofileä:
    self.objects = [NSMutableArray arrayWithContentsOfFile:path];
    
    /*
     
    //toistaiseksi luetaan plistissä olevat arrayt ja luodaan oliot:
     NSArray *ajankayttokohteet;
     NSArray *kuvat;
     NSArray *kaytetytAjat;
 
     
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    ajankayttokohteet = [dict objectForKey:@"Nimet"];
    kuvat = [dict objectForKey:@"Kuvat"];
    kaytetytAjat = [dict objectForKey:@"AjatMinuutteina"];
    _objects = [NSMutableArray arrayWithCapacity:[ajankayttokohteet count]];
    
    for (NSString *kohteennimi in ajankayttokohteet) {
        AjankayttoKohde *uusikohde = [[AjankayttoKohde alloc] init];
        uusikohde.nimi = kohteennimi;
        NSUInteger kohteenIndeksi = [ajankayttokohteet indexOfObject:kohteennimi]; //identifioidaan kohteet vain nimellä!
        uusikohde.aika = kaytetytAjat[kohteenIndeksi];
        uusikohde.kuva = kuvat[kohteenIndeksi];
        [_objects addObject:uusikohde];
    }
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OmaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *object = self.objects[indexPath.row];
    cell.nimiLabel.text = [object objectForKey:@"Nimi"];
    cell.aikaLabel.text = @"0";
    //cell.kuvaView.image = [UIImage imageNamed:object.kuva];
    //piirretäänkin kuva taustalle:
    cell.backgroundColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:[object objectForKey:@"Nimi"]]] colorWithAlphaComponent:0.3];
    
    cell.playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

@end
