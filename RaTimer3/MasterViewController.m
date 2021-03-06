//
//  MasterViewController.m
//  RaTimer3
//
//  Created by Riku Oja on 4.11.2014.
//  Copyright (c) 2014 Riku Oja. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "SettingsViewController.h"
#import "OmaTableViewCell.h"
#import "UIColor+RandomColors.h"
#import "UIColor+Hex.h"

@interface MasterViewController ()

//tallennettavien plistien sijainti:
@property (strong, nonatomic) NSString *kohteetPath;
@property (strong, nonatomic) NSString *asetuksetPath;
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
    self.ajanNayttotarkkuus = 60;
    self.naytettavaAikavali = NSCalendarUnitWeekOfMonth; //oletusarvot
    
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    
    //säädetään settings-napin logo ja fontti:
    self.navigationItem.rightBarButtonItem.title=@"\u2699";
    UIFont *customFont = [UIFont fontWithName:@"Helvetica" size:23.0];
    NSDictionary *fontDictionary = @{NSFontAttributeName : customFont};
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:fontDictionary forState:UIControlStateNormal];
    
    //lisätään add-nappi tuhoamatta settings-nappia:
    NSArray* oikeatNapit = [[NSArray alloc] initWithObjects:addButton, self.navigationItem.rightBarButtonItem, nil];
    self.navigationItem.rightBarButtonItems = oikeatNapit;
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    //asetetaan haluttu sijainti plisteille (tässä documentdirectory):
    self.kohteetPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.kohteetPath = [self.kohteetPath stringByAppendingPathComponent:@"TallennetutKohteet.plist"];
    self.asetuksetPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.asetuksetPath = [self.asetuksetPath stringByAppendingPathComponent:@"Asetukset.plist"];
    
    //kopioidaan documentdirectoryyn esimerkkikohteet ja oletusasetukset, jos plistejä ei löydy:
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:self.kohteetPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"TallennetutKohteet" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:self.kohteetPath error:nil];
    }
    [self lueKohteet];
    
    //ladataan asetukset:
    
    if (![fileManager fileExistsAtPath:self.asetuksetPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"Asetukset" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:self.asetuksetPath error:nil];
    }
    [self lueAsetukset];
    
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
    [uusiKohde setValue:[[UIColor randomLightColor] cssString] forKey:@"Vari"];
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
        NSMutableDictionary *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        //ei haluta detailia full screeniin:
        //controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        //dataa pitää siirtää detailviewistä takaisinpäin:
        controller.delegate=self;
    }
    if ([segue.identifier isEqualToString:@"naytaPopover"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        SettingsViewController *settingsViewController = navigationController.viewControllers.firstObject;
        UIPopoverPresentationController *popoverPresentaatioController = navigationController.popoverPresentationController;
        //masterview asetetaan settingsin popovercontrollerin delegaatiksi
        popoverPresentaatioController.delegate = self;
        //settingsviewcontrollerin IBOutletteja ei voi konfiguroida ennen segueta - viewtä ei ole alustettu
        //sen sijaan asetetaan masterview myös settingsviewcontrollerin delegaatiksi:
        settingsViewController.delegate = self;
    }

}

#pragma mark - Protocols

- (void) muuttunutKohde:(NSMutableDictionary *)kohde vanhaKohde:(NSMutableDictionary *)vanha {
    //etsitään kohteen numero arraysta (on voinut siirtyä) pointtereita vertaamalla:
    NSInteger kohteenNumero = [self.objects indexOfObject:vanha];
    self.objects[kohteenNumero] = kohde;
    [self tallennaKohteet];
    //ladataan vielä taulukon vastaava rivi uudestaan:
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:kohteenNumero inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    //tarvitaan uipopoverpresentationcontrollerdelegate-protokollaan!
    return UIModalPresentationNone;
}

- (void)paivitaTaulukko {
    [self.tableView reloadData];
}

- (void)valitseKohde:(NSInteger)kohde {
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kohde inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
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
    //piirretään taustaväri tai -kuva:
    cell.backgroundColor = [[UIColor colorWithCSS:object[@"Vari"]]colorWithAlphaComponent:0.5];
    //cell.backgroundColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:object[@"Vari"]]] colorWithAlphaComponent:0.3];
    
    //tarkistetaan, onko ajanotto käynnissä:
    if ([object[@"Kaytossa"] boolValue]) {
        cell.playButton.selected = YES;
        [cell.playIndikaattori startAnimating];
        //ajannäyttötarkkuus on voinut muuttua, muistettava päivittää myös ajastinten päivitysnopeus!
        //nollataan, mikäli vanha ajastin on olemassa:
        if (![self.ajastimet[indexPath.row] isEqual:[NSNull null]]) {
            [self.ajastimet[indexPath.row] invalidate];
            self.ajastimet[indexPath.row] = [NSNull null];
        }
        //aloitetaan uusi ajastin:
        NSTimer *ajastin = [NSTimer scheduledTimerWithTimeInterval:self.ajanNayttotarkkuus target:self selector:@selector(paivitaAika:) userInfo:indexPath repeats:YES];//userinfoksi laitetaan indexpath
        self.ajastimet[indexPath.row]=ajastin;
        
    } else {
        cell.playButton.selected = NO;
        [cell.playIndikaattori stopAnimating];
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
    //päivitetään vielä taulukko välittömästi:
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - NSTimer

- (void)paivitaAika:(NSTimer *)ajastin {
    //NSLog(@"Ajastimella userInfo %@", (NSIndexPath *)ajastin.userInfo);
    //Ei päivitetä näyttöä, jos käyttäjä on siirtämässä soluja (kaatuu päivitettäessä):
    if (!self.tableView.isEditing) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:ajastin.userInfo] withRowAnimation:UITableViewRowAnimationNone];
    }
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
    //NSLog(@"Jakson Alkupaivamaara %@", alkupaivamaara);
    //NSLog(@"Jakson pituus %f sekuntia",(double)jaksonPituus);
    //haetaan kohteesta ne aikavälit, jotka ovat halutun jakson sisällä.
    //uusimmat aikavälit tallentuvat arrayn loppuun, joten tehdään haku käänteisessä järjestyksessä:
    for (NSMutableDictionary *ajat in [kysyttyKohde[@"Ajat"] reverseObjectEnumerator]) {
        //NSLog(@"Aika alkoi %@", ajat[@"Alku"]);
        //NSLog(@"Aika alkoi %d päivää sitten",(int)[[kayttajanKalenteri components:NSCalendarUnitDay fromDate:ajat[@"Alku"] toDate:nykyhetki options:0] day]);
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
        //NSLog(@"Aikaa käytetty yhteensä %d h %d min %d s", (int)[palautettavatTunnit hour], (int)[palautettavatTunnit minute], (int)palautettavatTunnit.second);
        //tuliko lisää kokonaisia minuutteja?
        palautettavatTunnit.minute=(int)palautettavatTunnit.minute+(int)palautettavatTunnit.second/60;
        palautettavatTunnit.second=palautettavatTunnit.second%60;
        //tuliko lisää kokonaisia tunteja?
        palautettavatTunnit.hour=palautettavatTunnit.hour+(int)palautettavatTunnit.minute/60;
        palautettavatTunnit.minute=palautettavatTunnit.minute%60;
        //NSLog(@"Aikaa käytetty yhteensä %d h %d min %d s", (int)[palautettavatTunnit hour], (int)[palautettavatTunnit minute],(int)palautettavatTunnit.second);
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
    [self.objects writeToFile:self.kohteetPath atomically:YES];
    
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
    NSData *data = [NSData dataWithContentsOfFile:self.kohteetPath];
    self.objects = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainers format:&alkuperainenFormaatti error:&virhe];
    //luodaan samankokoinen tyhjä ajastinarray:
    self.ajastimet = [NSMutableArray arrayWithCapacity:self.objects.count];
    for (id kohde in self.objects) [self.ajastimet addObject:[NSNull null]];
}

- (void)tallennaAsetukset {
    //enumit ja typet muutettava objekteiksi:
    NSMutableDictionary* asetukset = [NSMutableDictionary dictionary];
    asetukset[@"ajanNayttotarkkuus"]=[NSNumber numberWithInt:self.ajanNayttotarkkuus];
    asetukset[@"naytettavaAikavali"]=[NSNumber numberWithInt:self.naytettavaAikavali];
    [asetukset writeToFile:self.asetuksetPath atomically:YES];
}

- (void)lueAsetukset {
    NSError *virhe;
    NSPropertyListFormat alkuperainenFormaatti;
    NSData *data = [NSData dataWithContentsOfFile:self.asetuksetPath];
    NSMutableDictionary* asetukset = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainers format:&alkuperainenFormaatti error:&virhe];
    //objektit muutettava inteiksi:
    self.ajanNayttotarkkuus = [asetukset[@"ajanNayttotarkkuus"] intValue];
    self.naytettavaAikavali = [asetukset[@"naytettavaAikavali"] intValue];
}

@end
