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
@property (nonatomic) NSTimeInterval ajanNayttotarkkuus;
//miltä aikaväliltä kulunut aika näytetään:
@property (nonatomic) NSCalendarUnit naytettavaAikavali;
//tallennetaan ruudunpäivityksestä vastaavat ajastimet toiseen arrayhin (ei voi tallentaa plistiin):
@property (strong, nonatomic) NSMutableArray *ajastimet;
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
    self.ajanNayttotarkkuus = 1; //sekunteina (oletusarvo 15 minuuttia=900 sekuntia)
    self.naytettavaAikavali = NSCalendarUnitWeekOfYear; //oletusarvot
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    //initialisoidaan uusi ajankäyttökohde:
    NSMutableDictionary *uusiKohde = [NSMutableDictionary dictionary];
    [uusiKohde setValue:@"Uusi kohde" forKey:@"Nimi"];
    [uusiKohde setValue:@"" forKey:@"Kuva"];
    [uusiKohde setValue:@NO forKey:@"Kaytossa"];
    [uusiKohde setValue:[NSMutableArray array] forKey:@"Ajat"];
    //lisätään kohde luetteloon:
    [self.objects insertObject:uusiKohde atIndex:0];
    //lisätään vastaava ajastin:
    [self.ajastimet insertObject:[NSNull null] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    //tallennetaan uusi kohde plistiin:
    [self tallennaKohteet];
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
    //sallitaan solujen siirtely:
    cell.showsReorderControl = YES;

    NSMutableDictionary *object = self.objects[indexPath.row];
    cell.nimiLabel.text = object[@"Nimi"];
    cell.aikaLabel.text = [self aikaaKulunutSelkokielella:[self aikaaKulunut:object aikavalilla:self.naytettavaAikavali]];
    //piirretään kuva taustalle:
    cell.backgroundColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:object[@"Kuva"]]] colorWithAlphaComponent:0.3];
    //cell.playButton = [UIButton buttonWithType:UIButtonTypeSystem]; ei pidä luoda uutta nappia, tuhoaa ib:n tekemän napin ominaisuuksineen =)
    //tarkistetaan, onko ajanotto käynnissä:
    if ([object[@"Kaytossa"] boolValue]) {
        cell.playButton.selected = YES;
        //aloitetaan ajastin, jos sitä ei vielä ole (kohteet vasta ladattu tiedostosta):
        if ([self.ajastimet[indexPath.row] isEqual:[NSNull null]]) {
            NSTimer *ajastin = [NSTimer scheduledTimerWithTimeInterval:self.ajanNayttotarkkuus target:self selector:@selector(paivitaAika:) userInfo:indexPath repeats:YES];//userinfoksi laitetaan indexpath
            self.ajastimet[indexPath.row]=ajastin;
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        //lopetetaan ja poistetaan ajastin samalla:
        if (![self.ajastimet[indexPath.row] isEqual:[NSNull null]]) [self.ajastimet[indexPath.row] invalidate];
        [self.ajastimet removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self tallennaKohteet];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //päivitettävä sekä kohteiden että ajastimien järjestys:
    NSMutableDictionary *siirrettavaKohde = self.objects[sourceIndexPath.row];
    NSTimer *siirrettavaAjastin = self.ajastimet[sourceIndexPath.row];
    [self.objects removeObjectAtIndex:sourceIndexPath.row];
    [self.ajastimet removeObjectAtIndex:sourceIndexPath.row];
    [self.objects insertObject:siirrettavaKohde atIndex:destinationIndexPath.row];
    [self.ajastimet insertObject:siirrettavaAjastin atIndex:destinationIndexPath.row];
    [self tallennaKohteet];
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
        [valittuKohde setValue:@NO forKey:@"Kaytossa"]; //dictionaryssa YES ja NO pitää wrapata objektiin literaalilla @
        //lisää lopetusajan Ajat-arrayn viimeiseen dictionaryyn:
        [[valittuKohde[@"Ajat"] lastObject] setValue:[NSDate date] forKey:@"Loppu"];
        //lopetetaan mahdollinen ajastin:
        if (![self.ajastimet[indexPath.row] isEqual:[NSNull null]]) {
            [self.ajastimet[indexPath.row] invalidate];
            self.ajastimet[indexPath.row] = [NSNull null];
        }
    }
    else {
        [valittuKohde setValue:@YES forKey:@"Kaytossa"];
        //lisätään aloitusaika Ajat-arrayhin uuteen dictionaryyn:
        [valittuKohde[@"Ajat"] addObject: [NSMutableDictionary dictionaryWithObject:[NSDate date] forKey:@"Alku"]];
        //aloita ajastin taulukon päivitystä varten, ajanoton tarkkuus määräytyy asetuksista:
        NSTimer *ajastin = [NSTimer scheduledTimerWithTimeInterval:self.ajanNayttotarkkuus target:self selector:@selector(paivitaAika:) userInfo:indexPath repeats:YES]; //userinfoksi laitetaan indexpath
        self.ajastimet[indexPath.row] = ajastin;
    }
    //tallennetaan dictionary takaisin arrayhin ja plistiin:
    self.objects[indexPath.row] = valittuKohde;
    [self tallennaKohteet];
}

#pragma mark - NSTimer

- (void)paivitaAika:(NSTimer *)ajastin {
    //ajastimen userInfo on halutun kohteen indexpath:
    NSLog(@"Ajastimella userInfo %@", (NSIndexPath *)ajastin.userInfo);
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:ajastin.userInfo] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - NSDate

- (NSDateComponents *)aikaaKulunut:(NSMutableDictionary *)kysyttyKohde aikavalilla:(NSCalendarUnit)haluttuAikavali {
    //NScalendaria tarvitaan kalenterilaskujen tekemiseen:
    NSCalendar *kayttajanKalenteri = [NSCalendar currentCalendar];
    NSDate *nykyhetki = [[NSDate alloc] init];
    //NSDateComponents-olio voi sisältää kuinka monta tuntia tahansa (ei käytetä päiviä jne):
    NSDateComponents *palautettavatTunnit = [[NSDateComponents alloc] init];
    palautettavatTunnit.hour=0;
    palautettavatTunnit.minute=0;
    palautettavatTunnit.second=0;
    //selvitetään kuluvan päivän/viikon/kuukauden/vuoden alkupäivämäärä:
    NSDate *alkupaivamaara;
    NSTimeInterval jaksonPituus;
    [kayttajanKalenteri rangeOfUnit:haluttuAikavali startDate:&alkupaivamaara interval:&jaksonPituus forDate:nykyhetki];
    NSLog(@"Jakson Alkupaivamaara %@", alkupaivamaara);
    NSLog(@"Jakson pituus %f sekuntia",(double)jaksonPituus);
    //haetaan kohteesta ne aikavälit, jotka ovat halutun jakson sisällä.
    //uusimmat aikavälit tallentuvat arrayn loppuun, joten tehdään haku käänteisessä järjestyksessä:
    for (NSMutableDictionary *ajat in [kysyttyKohde[@"Ajat"] reverseObjectEnumerator]) {
        NSLog(@"Aika alkoi %@", ajat[@"Alku"]);
        NSLog(@"Aika alkoi %d päivää sitten",(int)[[kayttajanKalenteri components:NSCalendarUnitDay fromDate:ajat[@"Alku"] toDate:nykyhetki options:0] day]);
        BOOL lopeta=NO;
        NSDate *alkuhetki, *loppuhetki;
        //tarkistetaan, onko ajanotto edelleen käynnissä:
        if (ajat[@"Loppu"] == nil) loppuhetki = nykyhetki;
        //tarkistetaan, loppuiko kohde ennen aikavälin alkua:
        else if ([alkupaivamaara earlierDate:ajat[@"Loppu"]] != alkupaivamaara) {
            //ajat tallennettu kronologisessa järjestyksessä eli vanhempia aikoja ei haluta käydä läpi:
            lopeta=YES;
            break;
        }
        else loppuhetki = ajat[@"Loppu"];
        //tarkistetaan, alkoiko kohde ennen aikavälin alkua:
        if ([alkupaivamaara earlierDate:ajat[@"Alku"]] != alkupaivamaara) {
            alkuhetki = alkupaivamaara;
            //ajat tallennettu kronologisessa järjestyksessä eli vanhempia aikoja ei haluta käydä läpi:
            lopeta=YES;
        }
        else alkuhetki = ajat[@"Alku"];
        //tallennetaan varalta sekunnit (voivat summautua minuuteiksi):
        NSDateComponents *lisattavaAika = [kayttajanKalenteri components:(NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:alkuhetki toDate:loppuhetki options:0];
        palautettavatTunnit.hour = palautettavatTunnit.hour+(int)lisattavaAika.hour;
        palautettavatTunnit.minute = palautettavatTunnit.minute+(int)lisattavaAika.minute;
        palautettavatTunnit.second = palautettavatTunnit.second+(int)lisattavaAika.second;
        NSLog(@"Aikaa käytetty yhteensä %d h %d min %d s", (int)[palautettavatTunnit hour], (int)[palautettavatTunnit minute], (int)palautettavatTunnit.second);
        //tuliko lisää kokonaisia minuutteja?
        palautettavatTunnit.minute=(int)palautettavatTunnit.minute+(int)palautettavatTunnit.second/60;
        palautettavatTunnit.second=palautettavatTunnit.second%60;
        //tuliko lisää kokonaisia tunteja?
        palautettavatTunnit.hour=palautettavatTunnit.hour+(int)palautettavatTunnit.minute/60;
        palautettavatTunnit.minute=palautettavatTunnit.minute%60;
        NSLog(@"Aikaa käytetty yhteensä %d h %d min %d s", (int)[palautettavatTunnit hour], (int)[palautettavatTunnit minute],(int)palautettavatTunnit.second);
        if (lopeta) break;
    }
    return palautettavatTunnit;
}

- (NSString *)aikaaKulunutSelkokielella:(NSDateComponents *)aikaaKulunut{
    //halutaan esittää aika muodossa HHH:mm
    NSNumberFormatter *muotoilu = [[NSNumberFormatter alloc] init];
    [muotoilu setPaddingCharacter:@"0"];
    [muotoilu setMinimumIntegerDigits:2];
    //tulostettava string riippuu halutusta näyttötarkkuudesta, NSTimeInterval ajannayttotarkkuus on sekunteina:
    NSNumber *tunnit = [NSNumber numberWithInteger:[aikaaKulunut hour]];
    NSNumber *minuutit = [NSNumber numberWithInteger:(int)([aikaaKulunut minute]/(self.ajanNayttotarkkuus/60))*(int)self.ajanNayttotarkkuus/60]; //(int)-castaus pyöristää alaspäin (ajannayttotarkkuus/60) minuutin tarkkuuteen
    return [NSString stringWithFormat:@"%@:%@", [muotoilu stringFromNumber:tunnit], [muotoilu stringFromNumber:minuutit]];
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
    //luodaan samankokoinen tyhjä ajastinarray:
    self.ajastimet = [NSMutableArray arrayWithCapacity:self.objects.count];
    for (id kohde in self.objects) [self.ajastimet addObject:[NSNull null]];
}

@end
