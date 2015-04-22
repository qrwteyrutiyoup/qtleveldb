import QtQuick 2.3
import QtTest 1.0
import QtLevelDB 1.0

TestCase {
    name: "QtLeveldbTest"
    property url source: Qt.resolvedUrl("test.db")
    function init() {
    }

    function cleanup() {
    }

    function initTestCase() {
        db.source = Qt.resolvedUrl("")
    }

    function cleanupTestCase() {
        db.destroyDB(source)
    }

    function test_create() {
        db.source = source
        compare(db.opened, true, db.statusText)
        db.source = Qt.resolvedUrl("")
        compare(db.opened, false, db.statusText)
    }

    function test_destroy() {
        db.source = Qt.resolvedUrl("test2.db")
        compare(db.opened, true, db.statusText)
        db.source = Qt.resolvedUrl("")
        compare(db.opened, false, db.statusText)
        compare(db.destroyDB(Qt.resolvedUrl("test.db")), LevelDB.Ok)
    }

    function test_repair() {
        compare(db.repairDB(source), LevelDB.Ok)
    }

    function test_sync_put_get(){
        db.source = source
        compare(db.opened, true, db.statusText)
        compare(db.putSync("asdf", "asdf"), LevelDB.Ok, "should be ok")
        db.get("asdf", function (status, result){
            compare(status, LevelDB.Ok, "should be ok")
            compare(result, "asdf", "value in get is diferent from put")
        })
    }

    function test_delete(){
        db.source = source
        compare(db.opened, true, db.statusText)
        compare(db.put("asdf", "asdf"), LevelDB.Ok)
        compare(db.del("asdf"), LevelDB.Ok)
        db.get("asdf", function (status, result){
            compare(status, LevelDB.NotFound, "should be not found!")
        })
    }

    function test_batch(){
        db.source = source
        compare(db.opened, true, db.statusText)
        console.log("BATCH: " + db.batch())
        var status = db.batch()
                        .put("asdf","asdf")
                        .put("asdf2", "asdf2")
                        .del("asdf")
                        .write()
        compare(status, LevelDB.Ok, "Batch Operation Failed")
        db.get("asdf", function (status, result){
            compare(status, LevelDB.NotFound, "Key should have been deleted")
        })
        db.get("asdf2", function (status, result){
            compare(status, LevelDB.Ok, "Key should exist")
            compare(result, "asdf2", "Wrong data")
        })
    }

    LevelDB{
        id:db
        options{
            compressionType: Options.SnappyCompression
            createIfMissing: true
            errorIfExists: false
            paranoidChecks: false
        }
    }
}

