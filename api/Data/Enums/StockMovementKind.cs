namespace Al3b.Api.Data.Enums;

public enum StockMovementKind
{
    // Staff bought more: quantity is how many arrived (> 0).
    Purchase,

    // Staff opened a tin/packet for use (> 0, usually 1). Only for items a sale does not deduct (tea, coffee).
    Opened,

    // Staff counted the shelf: quantity is what is there now (>= 0). Resets on_hand.
    Count
}
