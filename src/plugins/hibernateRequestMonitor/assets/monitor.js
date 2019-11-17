function formatTableCell(cellValue) {
    if (typeof cellValue == 'string') {
        if (stringContainsSql(cellValue)) {
            return getFromClause(cellValue).trim();
        }
        return replaceLineBreaks(cellValue);
    }
    return cellValue;
}

function replaceLineBreaks(stringValue) {
    return stringValue.replace(/(?:\r\n|\r|\n)/g, '<br>');
}

function removeSqlSelect(stringValue) {
    return stringValue.replace(/(?<=select)(([\s\S])*)(?=from)+/gi, ' ...\n');
}

function getFromClause(stringValue) {
    var match = stringValue.match(/(?<=from\s)(([\s\S])*)(?=where\s)+/gi);
    console.log(typeof match);
    if (match == null) {
        return '';
    }

    return match[0];
}

function stringContainsSql(stringValue) {
    var match = stringValue.match(/(from\s)+/gi);
    return !(match == null);
}

// make modal draggable
$(function() {
    $('.modal-header').on('mousedown', function(mousedownEvt) {
        var $draggable = $(this);
        var x = mousedownEvt.pageX - $draggable.offset().left,
            y = mousedownEvt.pageY - $draggable.offset().top;
        $('body').on('mousemove.draggable', function(mousemoveEvt) {
            $draggable.closest('.modal-dialog').offset({
                left: mousemoveEvt.pageX - x,
                top: mousemoveEvt.pageY - y
            });
        });
        $('body').one('mouseup', function() {
            $('body').off('mousemove.draggable');
        });
        $draggable.closest('.modal').one('bs.modal.hide', function() {
            $('body').off('mousemove.draggable');
        });
    });
});
