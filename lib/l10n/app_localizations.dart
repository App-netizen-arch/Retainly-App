import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Retainly'**
  String get appName;

  /// No description provided for @studyNow.
  ///
  /// In en, this message translates to:
  /// **'Study Now'**
  String get studyNow;

  /// No description provided for @planner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get planner;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjects;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @revisionQueue.
  ///
  /// In en, this message translates to:
  /// **'Revision Queue'**
  String get revisionQueue;

  /// No description provided for @resources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @examMode.
  ///
  /// In en, this message translates to:
  /// **'Exam Mode'**
  String get examMode;

  /// No description provided for @onTrack.
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get onTrack;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get needsAttention;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Add your first task to get started.'**
  String get noTasks;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @postpone.
  ///
  /// In en, this message translates to:
  /// **'Postpone'**
  String get postpone;

  /// No description provided for @needMorePractice.
  ///
  /// In en, this message translates to:
  /// **'Need more practice'**
  String get needMorePractice;

  /// No description provided for @saveTask.
  ///
  /// In en, this message translates to:
  /// **'Save Task'**
  String get saveTask;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmOverwrite.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite existing data. Continue?'**
  String get confirmOverwrite;

  /// No description provided for @overwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get overwrite;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export complete'**
  String get exportSuccess;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import complete'**
  String get importSuccess;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// No description provided for @noExportFile.
  ///
  /// In en, this message translates to:
  /// **'No export file found'**
  String get noExportFile;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importing;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get backupNow;

  /// No description provided for @backupHistory.
  ///
  /// In en, this message translates to:
  /// **'Backup History'**
  String get backupHistory;

  /// No description provided for @deleteBackup.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteBackup;

  /// No description provided for @examCountdown.
  ///
  /// In en, this message translates to:
  /// **'Exam Countdown'**
  String get examCountdown;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'days remaining'**
  String get daysRemaining;

  /// No description provided for @totalStudyTime.
  ///
  /// In en, this message translates to:
  /// **'Total Study Time'**
  String get totalStudyTime;

  /// No description provided for @chaptersCompleted.
  ///
  /// In en, this message translates to:
  /// **'Chapters Completed'**
  String get chaptersCompleted;

  /// No description provided for @studyTimeLearning.
  ///
  /// In en, this message translates to:
  /// **'Study Time Learning'**
  String get studyTimeLearning;

  /// No description provided for @noSubjects.
  ///
  /// In en, this message translates to:
  /// **'No subjects yet. Add your first subject in the Subjects tab.'**
  String get noSubjects;

  /// No description provided for @noChapters.
  ///
  /// In en, this message translates to:
  /// **'No chapters yet. Add chapters to start tracking progress.'**
  String get noChapters;

  /// No description provided for @noRevisionsDue.
  ///
  /// In en, this message translates to:
  /// **'No revisions due right now. Keep up the good work!'**
  String get noRevisionsDue;

  /// No description provided for @noResources.
  ///
  /// In en, this message translates to:
  /// **'No resources yet. Attach PDFs or images to your subjects.'**
  String get noResources;

  /// No description provided for @noPracticals.
  ///
  /// In en, this message translates to:
  /// **'No practical records yet.'**
  String get noPracticals;

  /// No description provided for @noTasksForToday.
  ///
  /// In en, this message translates to:
  /// **'No tasks for today. Great job staying on track!'**
  String get noTasksForToday;

  /// No description provided for @addFirstTask.
  ///
  /// In en, this message translates to:
  /// **'Add your first task to build today\'s plan.'**
  String get addFirstTask;

  /// No description provided for @examWithin.
  ///
  /// In en, this message translates to:
  /// **'Exam within'**
  String get examWithin;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @atRisk.
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get atRisk;

  /// No description provided for @behindSchedule.
  ///
  /// In en, this message translates to:
  /// **'Behind Schedule'**
  String get behindSchedule;

  /// No description provided for @remainingMinutes.
  ///
  /// In en, this message translates to:
  /// **'Remaining minutes'**
  String get remainingMinutes;

  /// No description provided for @availableMinutes.
  ///
  /// In en, this message translates to:
  /// **'Available minutes'**
  String get availableMinutes;

  /// No description provided for @highPriorityChapters.
  ///
  /// In en, this message translates to:
  /// **'High Priority Chapters'**
  String get highPriorityChapters;

  /// No description provided for @revisionPlanPreview.
  ///
  /// In en, this message translates to:
  /// **'Revision Plan Preview'**
  String get revisionPlanPreview;

  /// No description provided for @acceptPlan.
  ///
  /// In en, this message translates to:
  /// **'Accept Plan'**
  String get acceptPlan;

  /// No description provided for @dismissPlan.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissPlan;

  /// No description provided for @viewAllChapters.
  ///
  /// In en, this message translates to:
  /// **'View all chapters'**
  String get viewAllChapters;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @dataHealthStatus.
  ///
  /// In en, this message translates to:
  /// **'Data Health Status'**
  String get dataHealthStatus;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportProblem;

  /// No description provided for @reportOutdatedContent.
  ///
  /// In en, this message translates to:
  /// **'Report outdated content'**
  String get reportOutdatedContent;

  /// No description provided for @deleteAccountAndData.
  ///
  /// In en, this message translates to:
  /// **'Delete Account and All Data'**
  String get deleteAccountAndData;

  /// No description provided for @sessionNotes.
  ///
  /// In en, this message translates to:
  /// **'Session notes'**
  String get sessionNotes;

  /// No description provided for @parkingLot.
  ///
  /// In en, this message translates to:
  /// **'Parking lot (distractions)'**
  String get parkingLot;

  /// No description provided for @howDidThisSessionGo.
  ///
  /// In en, this message translates to:
  /// **'How did this session go?'**
  String get howDidThisSessionGo;

  /// No description provided for @understoodIt.
  ///
  /// In en, this message translates to:
  /// **'Understood it'**
  String get understoodIt;

  /// No description provided for @couldNotFinish.
  ///
  /// In en, this message translates to:
  /// **'Could not finish'**
  String get couldNotFinish;

  /// No description provided for @minimumViableDay.
  ///
  /// In en, this message translates to:
  /// **'Minimum viable day'**
  String get minimumViableDay;

  /// No description provided for @focusOnOneTask.
  ///
  /// In en, this message translates to:
  /// **'Focus on one manageable task'**
  String get focusOnOneTask;

  /// No description provided for @startThisTask.
  ///
  /// In en, this message translates to:
  /// **'Start this task'**
  String get startThisTask;

  /// No description provided for @overduePrioritize.
  ///
  /// In en, this message translates to:
  /// **'Overdue — prioritize this task'**
  String get overduePrioritize;

  /// No description provided for @dueTodayFocus.
  ///
  /// In en, this message translates to:
  /// **'Due today — focus on this'**
  String get dueTodayFocus;

  /// No description provided for @dueInDaysStartSoon.
  ///
  /// In en, this message translates to:
  /// **'Due in {days} days — start soon'**
  String dueInDaysStartSoon(Object days);

  /// No description provided for @highPriorityTask.
  ///
  /// In en, this message translates to:
  /// **'High priority task'**
  String get highPriorityTask;

  /// No description provided for @fitsDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Fits within your daily limit'**
  String get fitsDailyLimit;

  /// No description provided for @breakIntoSmallerSteps.
  ///
  /// In en, this message translates to:
  /// **'Consider breaking this into smaller steps'**
  String get breakIntoSmallerSteps;

  /// No description provided for @objective.
  ///
  /// In en, this message translates to:
  /// **'Objective'**
  String get objective;

  /// No description provided for @apparatusMaterials.
  ///
  /// In en, this message translates to:
  /// **'Apparatus / Materials'**
  String get apparatusMaterials;

  /// No description provided for @procedureChecklist.
  ///
  /// In en, this message translates to:
  /// **'Procedure checklist'**
  String get procedureChecklist;

  /// No description provided for @observationResult.
  ///
  /// In en, this message translates to:
  /// **'Observation / Result'**
  String get observationResult;

  /// No description provided for @vivaQuestions.
  ///
  /// In en, this message translates to:
  /// **'Viva questions'**
  String get vivaQuestions;

  /// No description provided for @addPractical.
  ///
  /// In en, this message translates to:
  /// **'Add Practical Record'**
  String get addPractical;

  /// No description provided for @practicalTitle.
  ///
  /// In en, this message translates to:
  /// **'Practical title'**
  String get practicalTitle;

  /// No description provided for @dataHealthBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Backed up'**
  String get dataHealthBackedUp;

  /// No description provided for @dataHealthLocal.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get dataHealthLocal;

  /// No description provided for @dataHealthLocalRecommended.
  ///
  /// In en, this message translates to:
  /// **'Saved locally; backup recommended'**
  String get dataHealthLocalRecommended;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted. Thank you.'**
  String get reportSubmitted;

  /// No description provided for @contentReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Content report submitted.'**
  String get contentReportSubmitted;

  /// No description provided for @allDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All data deleted'**
  String get allDataDeleted;

  /// No description provided for @deleteAllDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your profile, tasks, chapters, focus sessions, revisions, resources, and practical records. This cannot be undone.'**
  String get deleteAllDataConfirm;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account and All Data'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your data. This cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account and all data deleted'**
  String get accountDeleted;

  /// No description provided for @noExamDateSet.
  ///
  /// In en, this message translates to:
  /// **'No exam date set'**
  String get noExamDateSet;

  /// No description provided for @examIsToday.
  ///
  /// In en, this message translates to:
  /// **'Exam is today'**
  String get examIsToday;

  /// No description provided for @examHasPassed.
  ///
  /// In en, this message translates to:
  /// **'Exam has passed'**
  String get examHasPassed;

  /// No description provided for @noTasksRecommended.
  ///
  /// In en, this message translates to:
  /// **'No tasks recommended. Add your first chapter or task to build today’s plan.'**
  String get noTasksRecommended;

  /// No description provided for @noTasksScheduledToday.
  ///
  /// In en, this message translates to:
  /// **'No tasks scheduled for today. Add a task from the planner.'**
  String get noTasksScheduledToday;

  /// No description provided for @tasksBeyondDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'tasks beyond daily limit'**
  String get tasksBeyondDailyLimit;

  /// No description provided for @completeMoreSessions.
  ///
  /// In en, this message translates to:
  /// **'Complete more sessions to see duration insights.'**
  String get completeMoreSessions;

  /// No description provided for @typicalSession.
  ///
  /// In en, this message translates to:
  /// **'Your typical study session is around {minutes} min.'**
  String typicalSession(Object minutes);

  /// No description provided for @tasksUsuallyTakeLonger.
  ///
  /// In en, this message translates to:
  /// **'Tasks usually take longer: {tasks}. Consider planning more time.'**
  String tasksUsuallyTakeLonger(Object tasks);

  /// No description provided for @planAccepted.
  ///
  /// In en, this message translates to:
  /// **'Plan accepted!'**
  String get planAccepted;

  /// No description provided for @planDismissed.
  ///
  /// In en, this message translates to:
  /// **'Plan dismissed'**
  String get planDismissed;

  /// No description provided for @revisionPlanAccepted.
  ///
  /// In en, this message translates to:
  /// **'Revision plan accepted!'**
  String get revisionPlanAccepted;

  /// No description provided for @revisionPlanDismissed.
  ///
  /// In en, this message translates to:
  /// **'Revision plan dismissed'**
  String get revisionPlanDismissed;

  /// No description provided for @noChaptersForRevision.
  ///
  /// In en, this message translates to:
  /// **'No chapters for revision'**
  String get noChaptersForRevision;

  /// No description provided for @noPracticesDue.
  ///
  /// In en, this message translates to:
  /// **'No practices due right now'**
  String get noPracticesDue;

  /// No description provided for @noResourcesYet.
  ///
  /// In en, this message translates to:
  /// **'No resources yet'**
  String get noResourcesYet;

  /// No description provided for @noPracticalsYet.
  ///
  /// In en, this message translates to:
  /// **'No practical records yet'**
  String get noPracticalsYet;

  /// No description provided for @noSubjectsYet.
  ///
  /// In en, this message translates to:
  /// **'No subjects yet'**
  String get noSubjectsYet;

  /// No description provided for @noChaptersYet.
  ///
  /// In en, this message translates to:
  /// **'No chapters yet'**
  String get noChaptersYet;

  /// No description provided for @noTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasksYet;

  /// No description provided for @noStudyPlan.
  ///
  /// In en, this message translates to:
  /// **'No study plan yet'**
  String get noStudyPlan;

  /// No description provided for @addSubject.
  ///
  /// In en, this message translates to:
  /// **'Add Subject'**
  String get addSubject;

  /// No description provided for @addChapter.
  ///
  /// In en, this message translates to:
  /// **'Add Chapter'**
  String get addChapter;

  /// No description provided for @addResource.
  ///
  /// In en, this message translates to:
  /// **'Add Resource'**
  String get addResource;

  /// No description provided for @addPracticalRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Practical Record'**
  String get addPracticalRecord;

  /// No description provided for @startFocusSession.
  ///
  /// In en, this message translates to:
  /// **'Start Focus Session'**
  String get startFocusSession;

  /// No description provided for @startRevision.
  ///
  /// In en, this message translates to:
  /// **'Start Revision'**
  String get startRevision;

  /// No description provided for @viewProgress.
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get viewProgress;

  /// No description provided for @viewSettings.
  ///
  /// In en, this message translates to:
  /// **'View Settings'**
  String get viewSettings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @useDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get useDarkTheme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @useLightTheme.
  ///
  /// In en, this message translates to:
  /// **'Use light theme'**
  String get useLightTheme;

  /// No description provided for @allowLocalReminders.
  ///
  /// In en, this message translates to:
  /// **'Allow local reminders'**
  String get allowLocalReminders;

  /// No description provided for @notificationsNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not supported on this platform.'**
  String get notificationsNotSupported;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// No description provided for @exportCSV.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportCSV;

  /// No description provided for @exportJSON.
  ///
  /// In en, this message translates to:
  /// **'Export Backup (JSON)'**
  String get exportJSON;

  /// No description provided for @importDocument.
  ///
  /// In en, this message translates to:
  /// **'Import Document'**
  String get importDocument;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from JSON Backup'**
  String get restoreBackup;

  /// No description provided for @overwriteAllData.
  ///
  /// In en, this message translates to:
  /// **'Overwrite all data?'**
  String get overwriteAllData;

  /// No description provided for @restoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will replace your current profile, tasks, chapters, focus sessions, revisions, resources, and practical records with the imported backup. This cannot be undone.'**
  String get restoreConfirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @dataRetentionPolicy.
  ///
  /// In en, this message translates to:
  /// **'Data Retention Policy'**
  String get dataRetentionPolicy;

  /// No description provided for @ageMinorPolicy.
  ///
  /// In en, this message translates to:
  /// **'Age & Minor Policy'**
  String get ageMinorPolicy;

  /// No description provided for @threatModel.
  ///
  /// In en, this message translates to:
  /// **'Threat Model'**
  String get threatModel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
