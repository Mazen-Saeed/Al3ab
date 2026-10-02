using Al3ab.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3ab.Api.Data.Configurations;

public class SessionProductConfiguration : IEntityTypeConfiguration<SessionProduct>
{
    public void Configure(EntityTypeBuilder<SessionProduct> builder)
    {
        builder.ToTable(t =>
        {
            t.HasCheckConstraint("ck_sessions_products_quantity", "quantity > 0");
            t.HasCheckConstraint("ck_sessions_products_unit_price", "unit_price >= 0");
        });
    }
}
