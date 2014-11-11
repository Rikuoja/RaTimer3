//
//  MasterViewController.m
//  RaTimer3
//
//  Created by Riku Oja on 4.11.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "OmaTableViewCell.h"

@interface MasterViewController ()

//tallennetaan kohteet yhteen arrayhin:
@property (strong, nonatomic) NSMutableArray *objects;
//tallennettavan plistin sijainti:
@property (strong, nonatomic) NSString *path;
//kuinka tarkkaan kulunut aika halutaan näyttää:
@property (nonatomic) NSTimeInterval ajanotonTarkkuus;
//miltä aikaväliltä kulunut aika näytetään:
@property (nonatomic) enum aikavalit naytettavaAikavali;
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
    
    //asetetaan haluttu sijainti plistille (tässä documentdirectory):
    self.path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.path = [self.path stringByAppendingPathComponent:@"TallennetutKohteet.plist"];
    
    //kopioidaan documentdirectoryyn testiplist, jos käyttäjällä ei ole plistiä:
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:self.path]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"TallennetutKohteet" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:self.path error:nil];
    }
    [self lueKohteet];
    
    //ladataan asetukset:
    self.ajanotonTarkkuus = 60; //oletusarvo 60 sekuntia
    self.naytettavaAikavali = aina; //oletusarvot
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

    NSMutableDictionary *object = self.objects[indexPath.row];
    cell.nimiLabel.text = object[@"Nimi"];
    cell.aikaLabel.text = [self aikaaKulunutSelkokielella:[self aikaaKulunut:object aikavalilla:self.naytettavaAikavali]];
    //piirretään kuva taustalle:
    cell.backgroundColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:object[@"Kuva"]]] colorWithAlphaComponent:0.3];
    cell.playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    //tarkistetaan, onko ajanotto käynnissä:
    if ([object[@"Kaytossa"] boolValue]) cell.playButton.selected = @YES;
        
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

#pragma mark - IBAction

- (IBAction)playPainettu:(UIButton *)sender {
    sender.selected = !sender.selected;
    //etsitään solu, joka sisältää buttonin:
    CGPoint painettuKohta = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:painettuKohta];
    //tallennetaan muutos kohteeseen:
    NSMutableDictionary *valittuKohde = self.objects[indexPath.row];
    //aloitetaan tai lopetetaan ajanotto tilanteen mukaan:
    if ([valittuKohde[@"Kaytossa"] boolValue]) {
        [valittuKohde setValue:@NO forKey:@"Kaytossa"];
        //lisää lopetusajan Ajat-arrayn viimeiseen dictionaryyn:
        [[valittuKohde[@"Ajat"] lastObject] setValue:[NSDate date] forKey:@"Loppu"];
        //lopetetaan mahdollinen ajastin:
    }
    else {
        [valittuKohde setValue:@YES forKey:@"Kaytossa"];
        //lisätään aloitusaika Ajat-arrayhin uuteen dictionaryyn:
        [valittuKohde[@"Ajat"] addObject: [NSMutableDictionary dictionaryWithObject:[NSDate date] forKey:@"Alku"]];
        //aloita ajastin taulukon päivitystä varten, ajanoton tarkkuus määräytyy asetuksista:
        [NSTimer scheduledTimerWithTimeInterval:self.ajanotonTarkkuus target:self selector:@selector(paivitaAika:) userInfo:valittuKohde repeats:@YES];
    }
    //tallennetaan dictionary takaisin arrayhin ja plistiin:
    self.objects[indexPath.row] = valittuKohde;
    [self tallennaKohteet];
}

#pragma mark - NSTimer

- (void)paivitaAika:(NSTimer *)ajastin {
    
}

#pragma mark - NSDate

- (NSDateComponents *)aikaaKulunut:(NSMutableDictionary *) kysyttyKohde aikavalilla:(enum aikavalit)haluttuAikavali {
    //NScalendaria tarvitaan kalenterilaskujen tekemiseen:
    NSCalendar *kayttajanKalenteri = [NSCalendar currentCalendar];
    NSDate *nykyhetki = [[NSDate alloc] init];
    NSDateComponents *palautettavatTunnit = [[NSDateComponents alloc] init];
    //selvitetään, monesko päivä viikossa, kuukaudessa, vuodessa on nyt?
    NSUInteger moneskoPaiva;
    switch (haluttuAikavali) {
        case paiva:
            moneskoPaiva = 1;
            break;
        case viikko:
            moneskoPaiva = [kayttajanKalenteri ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:nykyhetki];
            break;
        case kuukausi:
            moneskoPaiva = [kayttajanKalenteri ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:nykyhetki];
            break;
        case vuosi:
            moneskoPaiva = [kayttajanKalenteri ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:nykyhetki];
            break;
        case aina:
            moneskoPaiva = [nykyhetki timeIntervalSince1970]/(3600*24);
    }
    NSLog(@"Nyt on %d:s päivä",(int)moneskoPaiva);
    NSLog(@"Aikaa käytetty yhteensä %d h %d min", (int)[palautettavatTunnit hour], (int)[palautettavatTunnit minute]);
    //haetaan kohteesta ne aikavälit, jotka ovat haluttujen päivien sisällä:
    for (NSMutableDictionary *ajat in kysyttyKohde[@"Ajat"]) {
        NSLog(@"Aika alkoi %ld päivää sitten",[[kayttajanKalenteri components:NSCalendarUnitDay fromDate:ajat[@"Alku"] toDate:nykyhetki options:0] day]+1);
        //NSDateComponents-olio voi sisältää kuinka monta tuntia tahansa (ei käytetä päiviä jne):
        unsigned int kaytettavatYksikot = NSCalendarUnitHour | NSCalendarUnitMinute;
        //tarkistetaan, onko ajanotto edelleen käynnissä:
        if (ajat[@"Loppu"] == nil) {
            NSDateComponents *tuntejaJaMinuutteja = [kayttajanKalenteri components:kaytettavatYksikot fromDate:ajat[@"Alku"] toDate:nykyhetki options:0];
            palautettavatTunnit.hour = palautettavatTunnit.hour+tuntejaJaMinuutteja.hour;
            palautettavatTunnit.minute = palautettavatTunnit.minute+tuntejaJaMinuutteja.minute;
        }
        else {
            NSDateComponents *tuntejaJaMinuutteja = [kayttajanKalenteri components:kaytettavatYksikot fromDate:ajat[@"Alku"] toDate:ajat[@"Loppu"] options:0];
            palautettavatTunnit.hour = palautettavatTunnit.hour+tuntejaJaMinuutteja.hour;
            palautettavatTunnit.minute = palautettavatTunnit.minute+tuntejaJaMinuutteja.minute;
        }
        //tarkistetaan, alkoiko kohde ennen aikavälin alkua:
        if ([[kayttajanKalenteri components:NSCalendarUnitDay fromDate:ajat[@"Alku"] toDate:nykyhetki options:0] day]+1 > moneskoPaiva) {
            //tallennettava vielä homman loppuosa:
            
            //ajat tallennettu kronologisessa järjestyksessä!
            break;
        }
    }
    return palautettavatTunnit;
}

- (NSString *)aikaaKulunutSelkokielella:(NSDateComponents *)aikaaKulunut{
    return [NSString stringWithFormat:@"%d h %d min", (int)[aikaaKulunut hour], (int)[aikaaKulunut minute]];
}

#pragma mark - I/O

- (void)tallennaKohteet {
    //Tällä voi halutessaan luoda testiplistin uudestaan:
    /*self.objects = [NSMutableArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Opetus",@"Nimi",@"256px-Common_Squirrel.jpg",@"Kuva",@NO,@"Kaytossa", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Materiaali & suunnittelu",@"Nimi",@"256px-Common_Squirrel.jpg",@"Kuva",@NO,@"Kaytossa", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Muut työt",@"Nimi",@"256px-Common_Squirrel.jpg",@"Kuva",@NO,@"Kaytossa", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Opiskelu",@"Nimi",@"256px-Common_Squirrel.jpg",@"Kuva",@NO,@"Kaytossa", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Oravien ruokinta",@"Nimi",@"256px-Common_Squirrel.jpg",@"Kuva",@NO,@"Kaytossa", nil],nil];
     */
    
    [self.objects writeToFile:self.path atomically:YES];
    
    //Propertylistserialization tekee täsmälleen saman optiolla NSDataWritingAtomic:
    /*
     if (![NSPropertyListSerialization propertyList:self.objects isValidForFormat:kCFPropertyListXMLFormat_v1_0]) {
     NSLog(@"Sisältää plistiin sopimattomia olioita");
     }
     
     NSError *virhe;
     NSData *data = [NSPropertyListSerialization dataWithPropertyList:self.objects format:kCFPropertyListXMLFormat_v1_0 options:0 error:&virhe];
     if (data == nil) {
     NSLog(@"Virhe: ", virhe);
     }
     
     BOOL writeStatus = [data writeToFile:path options:NSDataWritingAtomic error:&virhe];
     */
}

- (void)lueKohteet {
    //luodaan tiedostosta mutablearray, jossa sisällä mutabledictionaryja:
    NSError *virhe;
    NSPropertyListFormat alkuperainenFormaatti;
    NSData *data = [NSData dataWithContentsOfFile:self.path];
    self.objects = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainers format:&alkuperainenFormaatti error:&virhe];
}

@end
