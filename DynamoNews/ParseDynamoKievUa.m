//
//  ParseDynamoKievUa.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 30.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "ParseDynamoKievUa.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "ArticleContent.h"
#import "TeamResults.h"
#import "PlayerStats.h"
#import "UserComment.h"


@implementation ParseDynamoKievUa

+ (NSMutableArray *)parseDynamoNewslinePage:(NSString *)page{
    //local page
    if (!page) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"dynamo_articles" ofType:@"html"];
        NSError *errorReading;
        page = [NSString stringWithContentsOfFile:filePath
                                         encoding:NSUTF8StringEncoding
                                            error:&errorReading];
    }
    //-local page
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *articles;
    if(bodyNode && !error){
        HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"id" matchingName:@"posts" allowPartial:NO];
        NSMutableArray *postsBetweenLiTags = [NSMutableArray arrayWithArray:[divIdPosts findChildTags:@"li"]];
        articles = [[NSMutableArray alloc] init];
        NSString *childNodeContent;
        for (HTMLNode *liNode in postsBetweenLiTags) {
            if ([liNode findChildWithAttribute:@"class" matchingName:@"post-head" allowPartial:NO]) {
                NSMutableArray *children = [NSMutableArray arrayWithArray:[liNode children]];
                ArticleContent *article = [[ArticleContent alloc] init];
                for (NSInteger i = children.count-1; i >= 0; i--){
                    if ([[children[i] tagName] isEqualToString:@"text"]) {
                        [children removeObjectAtIndex:i];
                    }
                }
                article.commentaryCount = [[[liNode findChildOfClass:@"comments"] contents] integerValue];
                for (HTMLNode *node in children) {
                    childNodeContent = [[node findChildTag:@"a"] getAttributeNamed:@"href"];
                    if (childNodeContent) {
                        if ([childNodeContent rangeOfString:@"#"].location == NSNotFound) {
                            if ([childNodeContent rangeOfString:@"news"].location != NSNotFound) {
                                article.articleType = NEWS_TYPE;
                            } else{
                                article.articleType = ARTICLE_TYPE;
                            }
                            
                            NSRange idRange = NSMakeRange(childNodeContent.length - 11, 6);
                            article.ID = [[childNodeContent substringWithRange:idRange] integerValue];
                        }
                    }
                    childNodeContent = [[node findChildTag:@"i"] contents];
                    if (childNodeContent) {
                        article.title = childNodeContent;
                    }
                    HTMLNode *imgNode = [node findChildTag:@"img"];
                    if ([[imgNode getAttributeNamed:@"width"] isEqualToString:@"160"]) {
                        article.mainImageLink = [imgNode getAttributeNamed:@"src"];
                    }
                    childNodeContent = [[node findChildTag:@"small"] contents];
                    if (childNodeContent) {
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        [dateFormat setDateFormat:@"dd.MM.yyyy, HH:mm"];
                        NSDate *pubDate = [dateFormat dateFromString:childNodeContent];
                        article.publishedDate = pubDate;
                    }
                    HTMLNode *divContent = [[node findChildWithAttribute:@"class" matchingName:@"nodeImg" allowPartial:NO] parent];
                    if (divContent) {
                        NSArray *pNodes = [divContent findChildTags:@"p"];
                        NSMutableString *articleContent = [[NSMutableString alloc] init];
                        for (HTMLNode *pNode in pNodes) {
                            if (![[pNode allContents] hasPrefix:@"Читать"]) {
                                [articleContent appendString:[pNode allContents]];
                                [articleContent appendString:@"\n"];
                            }
                        }
                        article.content = articleContent;
                    }
                }
                article.isLoaded = NO;
                [articles addObject:article];
            }
        }
    }
    return articles;
}

+(void)parseDynamoArticlePage:(NSString *)page savingTo:(ArticleContent *)article{
    
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    if(bodyNode && !error){
        HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"id" matchingName:@"posts" allowPartial:NO];
        NSArray *articleContent = [divIdPosts children];
        NSString *childNodeContent = [[NSString alloc] init];
        
        for (HTMLNode *node in articleContent) {
            HTMLNode *sourceInfoNode = [node findChildOfClass:@"source"];
            HTMLNode *aNode = [sourceInfoNode findChildTag:@"a"];
            if (aNode) {
                NSString *sourceInfoURL = [aNode getAttributeNamed:@"href"];
                childNodeContent = [aNode contents];
                article.infoSource = childNodeContent;
                article.infoSourceURL = sourceInfoURL;
            }
            HTMLNode *contentNode = [[[node findChildWithAttribute:@"class" matchingName:@"nodeImg" allowPartial:NO] parent] parent];
            
            if (contentNode) {
                NSArray *contentChildren = [contentNode children];
                NSMutableArray *contentOfArticle = [[NSMutableArray alloc] init];
                NSString *tag;
                for (HTMLNode *node in contentChildren) {
                    tag = [node tagName];
                    if (![tag isEqualToString:@"text"]) {
                        if ([tag isEqualToString:@"p"]) {
                            HTMLNode *videoContent = [node findChildTag:@"object"];
                            if (videoContent) {
                                
                            } else {
                                [contentOfArticle addObject:[node allContents]];
                            }
                        }
                    }
                    NSLog(@"%@", [node tagName]);
                    NSLog(@"%@", [node rawContents]);
                }
                NSArray *pNodes = [contentNode findChildTags:@"p"];
                NSMutableString *articleContent = [[NSMutableString alloc] init];
                for (NSUInteger i = 0; i < pNodes.count; i++) {
                    if (i == 0) {
                        article.summary = [pNodes[i] allContents];
                    }else{
                        [articleContent appendString:[pNodes[i] allContents]];
                        [articleContent appendString:@"\n"];
                    }
                }
                article.content = articleContent;
                NSLog(@"");
            }
            childNodeContent = [[divIdPosts findChildWithAttribute:@"class"
                                                      matchingName:@"content"
                                                      allowPartial:NO] rawContents];
            if (childNodeContent) {
                NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                NSString *filename = [docsFolder stringByAppendingPathComponent:@"htmlContent.html"];
                NSError *error;
                [childNodeContent writeToFile:filename atomically:NO encoding:NSUTF8StringEncoding error:&error];
                NSURL *fileURL = [NSURL fileURLWithPath:filename];
                article.attributedContent = [[NSMutableAttributedString alloc] initWithFileURL:fileURL options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
                [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
                
            }
        }
        article.isLoaded = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadingSynchronization" object:nil];
    }
}

+ (void)parseBlogArticlePage:(NSString *)page savingTo:(ArticleContent *)article{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    if(bodyNode && !error){
        HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"class" matchingName:@"single" allowPartial:NO];
        NSString *childNodeContent = [[NSString alloc] init];
        childNodeContent = [[divIdPosts findChildWithAttribute:@"class" matchingName:@"content" allowPartial:NO] rawContents];
        if (childNodeContent) {
            NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *filename = [docsFolder stringByAppendingPathComponent:@"htmlContent.html"];
            NSError *error;
            [childNodeContent writeToFile:filename atomically:NO encoding:NSUTF8StringEncoding error:&error];
            
            NSURL *fileURL = [NSURL fileURLWithPath:filename];
            article.attributedContent = [[NSMutableAttributedString alloc] initWithFileURL:fileURL options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
        }
        article.isLoaded = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadingSynchronization" object:nil];
    }
}

+ (NSMutableArray *)parseBlogsPage:(NSString *)page{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *articles;
    
    if(bodyNode && !error){
        articles = [[NSMutableArray alloc] init];
        HTMLNode *divIdPosts = [bodyNode findChildWithAttribute:@"id" matchingName:@"posts" allowPartial:NO];
        NSMutableArray *posts = [NSMutableArray arrayWithArray:[divIdPosts findChildTags:@"li"]];
        NSString *childNodeContent;
        for (NSInteger i = posts.count-1; i >= 0; i--){
            HTMLNode *node = posts[i];
            if (![node findChildWithAttribute:@"class" matchingName:@"post-head" allowPartial:NO]) {
                [posts removeObjectAtIndex:i];
            }
        }
        for (HTMLNode *node in posts) {
            ArticleContent *article = [[ArticleContent alloc] init];
            article.articleType = BLOGS_TYPE;
            article.isLoaded = NO;
            HTMLNode *commentsNode = [node findChildWithAttribute:@"class" matchingName:@"comments" allowPartial:NO];
            childNodeContent = [commentsNode getAttributeNamed:@"href"];
            if (childNodeContent) {
                NSRange idRange = NSMakeRange(childNodeContent.length - 20, 6);
                article.ID = [[childNodeContent substringWithRange:idRange] integerValue];
            }
            article.commentaryCount = [[commentsNode contents] integerValue];
            childNodeContent = [[node findChildWithAttribute:@"class" matchingName:@" post-name" allowPartial:NO] contents];
            if (childNodeContent) {
                article.title = childNodeContent;
            }
            childNodeContent = [[node findChildWithAttribute:@"class" matchingName:@"fan-zona-text post-name" allowPartial:NO]contents];
            if (childNodeContent) {
                article.title = childNodeContent;
            }
            HTMLNode *author = [node findChildWithAttribute:@"width" matchingName:@"18" allowPartial:NO];
            if (author) {
                childNodeContent = [author getAttributeNamed:@"src"];
                if (childNodeContent) {
                    article.mainImageLink = childNodeContent;
                }
                childNodeContent = [author getAttributeNamed:@"alt"];
                if (childNodeContent) {
                    article.userName = childNodeContent;
                }
                childNodeContent = [[[[author parent] nextSibling] nextSibling] contents];
                if (childNodeContent) {
                    article.userName = [NSString stringWithFormat:@"%@ - %@", article.userName, childNodeContent];
                }
            }
            childNodeContent = [[node findChildWithAttribute:@"class" matchingName:@"muted" allowPartial:NO] allContents];
            if (childNodeContent) {
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"dd.MM.yyyy, HH:mm"];
                NSDate *pubDate = [dateFormat dateFromString:childNodeContent];
                article.publishedDate = pubDate;
            }
            [articles addObject:article];
        }
    }
    return articles;
}

+ (NSMutableArray *)parseMatchCenterFile:(NSString *)page{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *content;
    if (bodyNode && !error) {
        NSArray *tournaments = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"match-center__group active" allowPartial:NO];
        if (tournaments.count != 0) {
            content = [[NSMutableArray alloc] init];
            NSString *childNodeContent;
            for (HTMLNode *tournamentNode in tournaments) {
                NSMutableArray *tournament = [[NSMutableArray alloc] init];
                NSArray *matches = [tournamentNode findChildTags:@"tr"];
                childNodeContent = [[tournamentNode findChildWithAttribute:@"class" matchingName:@"match-center__head" allowPartial:NO] allContents];
                NSString *tournamentName = [childNodeContent stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                for (HTMLNode *matchNode in matches) {
                    MatchScoreInfo *match = [[MatchScoreInfo alloc] init];
                    match.tournament = tournamentName;
                    NSArray *matchContent = [matchNode findChildrenWithAttribute:@"class" matchingName:@"news-live-link_main news-live-link_main_h22" allowPartial:NO];
                    match.homeTeam = [[[matchContent firstObject] allContents] stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                    HTMLNode *scoreNode = [matchNode findChildTag:@"strong"];
                    childNodeContent = [[scoreNode nextSibling] allContents];
                    NSRange spaceRange = [childNodeContent rangeOfString:@" "];
                    if (spaceRange.location == 0) {
                        match.guestTeam = [childNodeContent substringFromIndex:1];
                    } else {
                        match.guestTeam = childNodeContent;
                    }
                    childNodeContent = [scoreNode contents];
                
                    if([childNodeContent rangeOfString:@"-"].location == NSNotFound){
                        childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSRange dashLocation = [childNodeContent rangeOfString:@":"];
                        match.guestTeamScore = [[childNodeContent substringFromIndex:dashLocation.location + 1] integerValue];
                        match.homeTeamScore = [[childNodeContent substringToIndex:dashLocation.location] integerValue];
                    } else {
                        match.guestTeamScore = -1;
                        match.homeTeamScore = -1;
                    }
                    NSDateFormatter *format = [[NSDateFormatter alloc] init];
                    format.dateFormat = @"dd MMMM HH:mm";
                    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"]];
                    childNodeContent = [[matchNode findChildWithAttribute:@"class" matchingName:@"date-cell" allowPartial:NO] allContents];
                    NSDate *temp = [format dateFromString:childNodeContent];
                    if (temp) {
                        format.dateFormat = @"dd.MM  HH:mm";
                        match.date = [format stringFromDate:temp];
                    } else {
                        match.date = childNodeContent;
                    }
                    match.link = [[matchNode findChildOfClass:@"bl-match"] getAttributeNamed:@"href"];
                    [tournament addObject:match];
                }
                [content addObject:tournament];
            }
        }
    }
    return content;
}

+(NSMutableArray *)parseLegueTablePage:(NSString *)page{
    
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *teams;
    if (bodyNode && !error) {
        teams = [[NSMutableArray alloc] init];
        NSArray *tours = [[bodyNode findChildOfClass:@"rightcol span4"] findChildrenOfClass:@"tour"];
        HTMLNode *lastPlayedTourNode = tours[0];
        NSString *pNodeContents = [[lastPlayedTourNode findChildTag:@"p"] allContents];
        NSRange openBracketRange = [pNodeContents rangeOfString:@"("];
        NSRange dotRange = [pNodeContents rangeOfString:@"."];
        NSString *lastPlayedTourStr;
        if(dotRange.location != NSNotFound){
            lastPlayedTourStr = [pNodeContents substringWithRange:NSMakeRange(openBracketRange.location + 1, dotRange.location - openBracketRange.location - 1)];        //fix it to get right value in non ukrainian championship!
        }
        NSNumber *lastPlayedTour = [[NSNumber alloc] initWithInteger:[lastPlayedTourStr integerValue]];
        HTMLNode *tbodyNode = [bodyNode findChildTag:@"tbody"];
        NSArray *teamsNode = [tbodyNode findChildTags:@"tr"];
        NSString *childNodeContent;
        for (HTMLNode *teamNode in teamsNode) {
            TeamResults *team = [[TeamResults alloc] init];
            NSArray *tdNodes = [teamNode findChildTags:@"td"];
            team.position = [[tdNodes[0] contents] integerValue];
            team.imageLink = [[tdNodes[1] findChildTag:@"img"] getAttributeNamed:@"src"];
            team.name = [[tdNodes[1] findChildTag:@"strong"] contents];
            team.city = [[tdNodes[1] findChildWithAttribute:@"class" matchingName:@"table-championship__city" allowPartial:NO] contents];
            team.gamesPlayed = [[tdNodes[2]contents] integerValue];
            team.wins = [[tdNodes[3]contents] integerValue];
            team.draws = [[tdNodes[4]contents] integerValue];
            team.defeats = [[tdNodes[5]contents] integerValue];
            childNodeContent = [tdNodes[6]contents];
            NSRange dashLocation = [childNodeContent rangeOfString:@"-"];
            team.goalsScored = [[childNodeContent substringToIndex:dashLocation.location] integerValue];
            team.goalsAgainst = [[childNodeContent substringFromIndex:dashLocation.location + 1] integerValue];
            team.points = [[tdNodes[7]contents] integerValue];
            [teams addObject:team];
        }
        [teams addObject:lastPlayedTour];
    }
    return teams;
}

+(NSMutableArray *)parseLegueSchedulePage:(NSString *)page{
    
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *tours;
    if (bodyNode && !error) {
        tours = [[NSMutableArray alloc] init];
        NSArray *tourPlayedNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"tour played wide_span4 span4" allowPartial:NO];
        NSMutableArray *tourNodes = [NSMutableArray arrayWithArray:tourPlayedNodes];
        NSArray *tourNotPlayedNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"tour  wide_span4 span4" allowPartial:NO];
        [tourNodes addObjectsFromArray:tourNotPlayedNodes];
        NSString *childNodeContent;
        for (HTMLNode *tourNode in tourNodes) {
            NSArray *trNodes = [tourNode findChildTags:@"tr"];
            NSMutableArray *singleTourMatches = [[NSMutableArray alloc] init];
            for (HTMLNode *tr in trNodes) {
                MatchScoreInfo *match = [[MatchScoreInfo alloc] init];
                NSArray *tdNodes = [tr findChildTags:@"td"];
                match.homeTeam = [[tdNodes firstObject] allContents];
                match.guestTeam = [[tdNodes lastObject] allContents];
                childNodeContent = [[tr findChildOfClass:@"result"] allContents];
                if (childNodeContent) {
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@" " withString:@""];
                    NSRange dashLocation = [childNodeContent rangeOfString:@":"];
                    match.homeTeamScore = [[childNodeContent substringToIndex:dashLocation.location] integerValue];
                    match.guestTeamScore = [[childNodeContent substringFromIndex:dashLocation.location + 1] integerValue];
                }
                childNodeContent = [[tr findChildOfClass:@"date"] allContents];
                if (childNodeContent) {
                    match.date = childNodeContent;
                    match.homeTeamScore = match.guestTeamScore = -1;
                }
                [singleTourMatches addObject:match];
            }
            [tours addObject:singleTourMatches];
        }
    }
    return tours;
}

+(NSMutableArray *)parseLegueScorersPage:(NSString *)page{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *players;
    if (bodyNode && !error) {
        players = [[NSMutableArray alloc] init];
        NSArray *tbodyNode = [[[bodyNode findChildOfClass:@"table-stats"] findChildTag:@"tbody"] findChildTags:@"tr"];
        for (HTMLNode *node in tbodyNode) {
            PlayerStats *player = [[PlayerStats alloc] init];
            NSArray *tdNodes = [node findChildTags:@"td"];
            NSString *nameAndTeam = [tdNodes[1] allContents];
            NSLog(@"%@", nameAndTeam);
            NSRange bracketsRange = [nameAndTeam rangeOfString:@"("];
            player.name = [nameAndTeam substringToIndex:bracketsRange.location - 1];
            bracketsRange.location++;
            bracketsRange.length = nameAndTeam.length - 2 - bracketsRange.location;
            player.team = [nameAndTeam substringWithRange:bracketsRange];
            player.goalsScored = [[tdNodes[2] contents] integerValue];
            player.homeGoals = [[tdNodes[3] contents] integerValue];
            player.guestGoals = [[tdNodes[4] contents] integerValue];
            player.penaltyScored = [[tdNodes[5] contents] integerValue];
            [players addObject:player];
        }
    }
    return players;
}

+(MatchScoreInfo *)parseCentralMatchPage:(NSString *)page{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    MatchScoreInfo *centralMatch;
    if (bodyNode && !error) {
        HTMLNode *bMatch = [bodyNode findChildOfClass:@"block-border"];
        if(bMatch){
            centralMatch = [[MatchScoreInfo alloc] init];
            centralMatch.tournament = [[bMatch findChildOfClass:@"b-match__head"] contents];
            NSArray *teamNameNodes = [bMatch findChildrenOfClass:@"b-match__body__name"];
            centralMatch.homeTeam = [teamNameNodes[0] contents];
            centralMatch.guestTeam = [teamNameNodes[1] contents];
            NSArray *teamCityNodes = [bMatch findChildrenOfClass:@"b-match__body__city"];
            centralMatch.homeTeamCity = [teamCityNodes[0] contents];
            centralMatch.guestTeamCity = [[teamCityNodes[1] contents] stringByReplacingOccurrencesOfString:@" " withString:@""];
            centralMatch.date = [[bMatch findChildOfClass:@"b-match__body-info"] contents];
            HTMLNode *teamNode = [bMatch findChildOfClass:@"b-match__body__left_pad"];
            NSString *matchScore = [[teamNode findChildWithAttribute:@"class" matchingName:@"b-counter-widg_num" allowPartial:YES] getAttributeNamed:@"class"];
            if (matchScore) {
                NSRange numRange = [matchScore rangeOfString:@"num"];
                centralMatch.homeTeamScore = [[matchScore substringFromIndex:numRange.location + 4] integerValue];
                matchScore = [[teamNode findChildOfClass:@"goal-name-wr"] allContents];
                if (matchScore) {
                    matchScore = [matchScore stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    matchScore = [matchScore substringWithRange:NSMakeRange(2, matchScore.length - 4)];
                    matchScore = [matchScore stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                    centralMatch.homeTeamScorers = [ParseDynamoKievUa nameOfScorersToArray:matchScore];
                }
                teamNode = [bMatch findChildOfClass:@"b-match__body__right_pad"];
                matchScore = [[teamNode findChildWithAttribute:@"class" matchingName:@"b-counter-widg_num" allowPartial:YES] getAttributeNamed:@"class"];
                numRange = [matchScore rangeOfString:@"num"];
                centralMatch.guestTeamScore = [[matchScore substringFromIndex:numRange.location + 4] integerValue];
                matchScore = [[teamNode findChildOfClass:@"goal-name-wr"] allContents];
                if (matchScore) {
                    matchScore = [matchScore stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    matchScore = [matchScore substringWithRange:NSMakeRange(2, matchScore.length - 4)];
                    matchScore = [matchScore stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                    centralMatch.guestTeamScorers = [ParseDynamoKievUa nameOfScorersToArray:matchScore];
                }
            } else {
                centralMatch.homeTeamScore = centralMatch.guestTeamScore = -1;
            }
        }
    }
    return centralMatch;
}

+(NSMutableDictionary *)parseTableAndCalendarPage:(NSString *)page{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    NSMutableDictionary *parsingResults;
    if (bodyNode) {
        parsingResults = [[NSMutableDictionary alloc] init];
        [self parseTableForGroupedTournamentsFromBodyNode:bodyNode savingTo:parsingResults];
        [self parseCalendarForGroupedTournamentsFromBodyNode:bodyNode savingTo:parsingResults];
    }
    return parsingResults;
}

+(NSArray *)nameOfScorersToArray:(NSString *)scorers{
    NSMutableArray *scorersArray = [[NSMutableArray alloc] init];
    NSRange nextLineSymbolRange = [scorers rangeOfString:@"\n"];
    while (nextLineSymbolRange.location != NSNotFound) {
        [scorersArray addObject:[scorers substringToIndex:nextLineSymbolRange.location]];
        scorers = [scorers substringFromIndex:nextLineSymbolRange.location + 1];
        nextLineSymbolRange = [scorers rangeOfString:@"\n"];
    }
    [scorersArray addObject:scorers];
    return scorersArray;
}

+(void)parseMatchDetailInfoPage:(NSString *)page savingTo:(MatchScoreInfo *)match{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    if (error) {
        NSLog(@"error:%@",error.description);
    } else {
        HTMLNode *bodyNode = [parser body];
        HTMLNode *homeTeamGoalsNode = [[bodyNode findChildOfClass:@"b-match__body__left"] findChildOfClass:@"b-match__goals"];
        NSArray *goalsNodes = [homeTeamGoalsNode findChildTags:@"li"];
        match.homeTeamScorers = [self getScorerDeletingName:goalsNodes];
        HTMLNode *guestTeamGoalsNode = [[bodyNode findChildOfClass:@"b-match__body__right"] findChildOfClass:@"b-match__goals b-match__goals_away"];
        goalsNodes = [guestTeamGoalsNode findChildTags:@"li"];
        match.guestTeamScorers = [self getScorerDeletingName:goalsNodes];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MatchDetailsPrepared" object:match];
}

+(NSMutableArray *)getScorerDeletingName:(NSArray *)goalsNodes{
    NSMutableArray *scorers = [[NSMutableArray alloc] init];
    for (HTMLNode *liNode in goalsNodes) {
        NSString *scorerNodeContent = [liNode allContents];
        scorerNodeContent = [scorerNodeContent stringByReplacingOccurrencesOfString:@"- " withString:@""];
        NSRange spaceRange = [scorerNodeContent rangeOfString:@" "];
        NSString *scorer = [scorerNodeContent substringToIndex:spaceRange.location];
        scorerNodeContent = [scorerNodeContent substringFromIndex:spaceRange.location + 1];
        spaceRange = [scorerNodeContent rangeOfString:@" "];
        if (spaceRange.location != NSNotFound) {
            scorerNodeContent = [scorerNodeContent substringFromIndex:spaceRange.location + 1];
        }
        scorer = [NSString stringWithFormat:@"%@ %@", scorer, scorerNodeContent];
        [scorers addObject:scorer];
    }
    return scorers;
}

+(void)parseCommentsPage:(NSString *)page savingTo:(ArticleContent *)article{
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:page error:&error];
    HTMLNode *bodyNode = [parser body];
    if (error) {
        NSLog(@"error:%@",error.description);
    } else {
        NSArray *liNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"comment-level" allowPartial:YES];
        if (liNodes.count != 0) {
            article.commentsContainer.comments = [[NSMutableArray alloc] init];
            NSString *temp;
            for (HTMLNode *liNode in liNodes) {
                UserComment *comment = [[UserComment alloc] init];
                temp = [liNode className];
                NSRange levelWordRange = [temp rangeOfString:@"level-"];
                NSRange levelNumberRange = NSMakeRange(levelWordRange.location + levelWordRange.length, 1);
                comment.level = [[temp substringWithRange:levelNumberRange] integerValue];
                if ([liNode findChildOfClass:@"deleted"]) {
                    comment.content = @"Комментарий удален";
                    [article.commentsContainer.comments addObject:comment];
                } else {
                    comment.username = [[liNode findChildOfClass:@"user"] contents];
                    temp = [[liNode findChildOfClass:@"comment-info"] allContents];
                    NSRange openBracketRange = [temp rangeOfString:@"("];
                    NSRange closeBracketRange = [temp rangeOfString:@")"];
                    temp = [temp substringWithRange:NSMakeRange(openBracketRange.location + 1, closeBracketRange.location - openBracketRange.location - 1)];
                    comment.username = [NSString stringWithFormat:@"%@ - %@", comment.username, temp];
                    comment.userLink = [[liNode findChildOfClass:@"user"] getAttributeNamed:@"href"];
                    comment.userStatus = [[liNode findChildWithAttribute:@"class" matchingName:@"js-title-name" allowPartial:YES] contents];
                    comment.date = [[[liNode findChildOfClass:@"pull-right"] findChildTag:@"span"] contents];
                    temp = [[liNode findChildOfClass:@"comment-content"] allContents];
                    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    temp = [temp stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
                    comment.content = temp;
                    HTMLNode *tempNode = [liNode findChildWithAttribute:@"class" matchingName:@"karma" allowPartial:YES];
                    comment.rating = [[[tempNode findChildWithAttribute:@"class" matchingName:@"rank" allowPartial:YES] contents] integerValue];
                    
                    [article.commentsContainer.comments addObject:comment];
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentsDownloaded" object:nil];
}

+(void)parseTableForGroupedTournamentsFromBodyNode:(HTMLNode *)bodyNode savingTo:(NSMutableDictionary *)parsingResults{
    NSArray *tbodyNodes = [bodyNode findChildTags:@"tbody"];
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    for (HTMLNode *tbody in tbodyNodes) {
        NSString *childNodeContent;
        NSMutableArray *teams = [[NSMutableArray alloc] initWithCapacity:4];
        NSArray *teamsNode = [tbody findChildrenOfClass:@"leader"];
        for (HTMLNode *teamNode in teamsNode) {
            TeamResults *team = [[TeamResults alloc] init];
            NSArray *tdNodes = [teamNode findChildTags:@"td"];
            childNodeContent = [[tdNodes[0] findChildTag:@"strong"] allContents];
            if (childNodeContent) {
                team.name = childNodeContent;
            }
            childNodeContent = [[tdNodes[0] findChildTag:@"span"] allContents];
            if (childNodeContent) {
                if ([childNodeContent hasPrefix:@" "]) {
                    childNodeContent = [childNodeContent substringFromIndex:1];
                }
                NSRange spaceLocation = [childNodeContent rangeOfString:@" "];
                team.city = [childNodeContent substringFromIndex:spaceLocation.location+1];
            }
            team.gamesPlayed = [[tdNodes[1]contents] integerValue];
            team.wins = [[tdNodes[2]contents] integerValue];
            team.draws = [[tdNodes[3]contents] integerValue];
            team.defeats = [[tdNodes[4]contents] integerValue];
            childNodeContent = [tdNodes[5]contents];
            NSRange dashLocation = [childNodeContent rangeOfString:@"-"];
            
            team.goalsScored = [[childNodeContent substringToIndex:dashLocation.location] integerValue];
            team.goalsAgainst = [[childNodeContent substringFromIndex:dashLocation.location + 1] integerValue];
            team.points = [[[tdNodes[6] findChildTag:@"strong"] contents] integerValue];
            [teams addObject:team];
        }
        [groups addObject:teams];
    }
    [parsingResults setObject:groups forKey:@"groupsTable"];
}

+(void)parseCalendarForGroupedTournamentsFromBodyNode:(HTMLNode *)bodyNode savingTo:(NSMutableDictionary *)parsingResults{
    NSMutableArray *groupsCalendar = [[NSMutableArray alloc] init];
    NSArray *groupNode = [bodyNode findChildrenOfClass:@"group span4"];
    NSString *childNodeContent;
    for (HTMLNode *group in groupNode) {
        NSMutableArray *groupMatches = [[NSMutableArray alloc] init];
        NSArray *liNodes = [[[group findChildTags:@"ul"] objectAtIndex:0] children];
        for (HTMLNode *liNode in liNodes) {
            if ([[liNode tagName] isEqualToString:@"li"]) {
                NSArray *matchesNodes = [liNode findChildTags:@"li"];
                for (HTMLNode *matchNode in matchesNodes) {
                    MatchScoreInfo *match = [[MatchScoreInfo alloc] init];
                    match.date = [[liNode findChildOfClass:@"group__match-date"] contents];
                    
                    HTMLNode *homeTeamNode = [[matchNode findChildOfClass:@"left"] findChildTag:@"strong"];
                    match.homeTeam = [homeTeamNode allContents];
                    childNodeContent = [[homeTeamNode nextSibling] allContents];
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@" " withString:@""];
                    match.homeTeamCity = [childNodeContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    HTMLNode *guestTeamNode = [[matchNode findChildOfClass:@"right"] findChildTag:@"strong"];
                    match.guestTeam = [guestTeamNode allContents];
                    childNodeContent = [[guestTeamNode nextSibling] allContents];
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@" " withString:@""];
                    match.guestTeamCity = [childNodeContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    
                    
                    childNodeContent = [[matchNode findChildWithAttribute:@"href" matchingName:@"match" allowPartial:YES] contents];
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@" " withString:@""];
                    childNodeContent = [childNodeContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    NSRange doubleDotsRange = [childNodeContent rangeOfString:@":"];
                    NSCharacterSet *digitsSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
                    if ([childNodeContent rangeOfCharacterFromSet:digitsSet].location != NSNotFound) {
                        match.homeTeamScore = [[childNodeContent substringToIndex:doubleDotsRange.location] integerValue];
                        match.guestTeamScore = [[childNodeContent substringFromIndex:doubleDotsRange.location + 1] integerValue];
                    } else {
                        match.homeTeamScore = match.homeTeamScore = -1;
                    }
                    [groupMatches addObject:match];
                }
            }
        }
        [groupsCalendar addObject:groupMatches];
    }
    [parsingResults setObject:groupsCalendar forKey:@"calendar"];
}
@end
