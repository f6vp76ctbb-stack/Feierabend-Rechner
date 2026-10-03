# Eigene R8-Regeln für den Release-Build (zusätzlich zu den Regeln der Bibliotheken).

# WorkManager (kommt über das Google-Mobile-Ads-SDK) legt beim App-Start seine
# Room-Datenbank an und erzeugt die generierte Klasse `WorkDatabase_Impl` per
# Reflection. Ohne diese Regel entfernt R8 (AGP 9, strikter Full Mode) den
# Standard-Konstruktor → „Failed to create an instance of androidx.work.impl.WorkDatabase"
# → Absturz bei jedem Start.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { <init>(); }
